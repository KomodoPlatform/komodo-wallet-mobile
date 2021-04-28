import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/orders/filters/filters.dart';
import 'package:komodo_dex/screens/dex/orders/swap/build_item_swap.dart';
import 'package:komodo_dex/screens/dex/orders/maker/build_item_maker.dart';
import 'package:komodo_dex/screens/dex/orders/taker/build_item_taker.dart';
import 'package:komodo_dex/widgets/pagination.dart';

class ActiveOrders extends StatefulWidget {
  const ActiveOrders({
    this.showFilters,
    this.activeFilters,
    this.onFiltersChange,
  });

  final bool showFilters;
  final Function(ActiveFilters) onFiltersChange;
  final ActiveFilters activeFilters;

  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  final _scrollCtrl = ScrollController();
  int _currentPage = 1;
  final int _perPage = 25;

  @override
  void initState() {
    ordersBloc.updateOrdersSwaps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
        initialData: ordersBloc.orderSwaps,
        stream: ordersBloc.outOrderSwaps,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) return SizedBox();

          List<dynamic> orderSwaps = snapshot.data;
          orderSwaps = snapshot.data.reversed.toList();
          final List<dynamic> orderSwapsFiltered = _filter(orderSwaps);

          final int start = (_currentPage - 1) * _perPage;
          int end = start + _perPage;
          if (end > orderSwapsFiltered.length) end = orderSwapsFiltered.length;
          final List<Widget> orderSwapsWidget = orderSwapsFiltered
              .map((dynamic item) {
                if (item is Swap) {
                  return BuildItemSwap(context: context, swap: item);
                } else if (item is Order) {
                  switch (item.orderType) {
                    case OrderType.MAKER:
                      return BuildItemMaker(item);
                    case OrderType.TAKER:
                      return BuildItemTaker(item);
                    default:
                      return SizedBox();
                  }
                } else {
                  return Container();
                }
              })
              .toList()
              .sublist(start, end);

          return SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showFilters) _buildFilters(orderSwaps),
                if (orderSwapsFiltered.isNotEmpty) ...{
                  _buildPagination(orderSwapsFiltered),
                  ...orderSwapsWidget,
                  _buildPagination(orderSwapsFiltered),
                },
                if (orderSwapsFiltered.isEmpty) ...{
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: const Center(
                        child: Text('No orders, please go to trade.')),
                  )
                },
                SizedBox(height: 10),
              ],
            ),
          );
        });
  }

  Widget _buildFilters(List<dynamic> orderSwaps) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 12, 4, 16),
        child: Filters(
          items: orderSwaps,
          activeFilters: widget.activeFilters,
          onChange: (ActiveFilters filters) {
            widget.onFiltersChange(filters);
          },
        ),
      ),
    );
  }

  List<dynamic> _filter(List<dynamic> unfiltered) {
    final List<dynamic> filtered = <dynamic>[];
    final String sellCoinFilter = widget.activeFilters?.sellCoin;
    final String receiveCoinFilter = widget.activeFilters?.receiveCoin;

    for (dynamic item in unfiltered) {
      String sellCoin;
      String receiveCoin;
      bool isMatched = true;

      if (item is Order) {
        sellCoin = item.orderType == OrderType.MAKER ? item.base : item.rel;
        receiveCoin = item.orderType == OrderType.MAKER ? item.rel : item.base;
      } else if (item is Swap) {
        sellCoin = item.isMaker ? item.makerAbbr : item.takerAbbr;
        receiveCoin = item.isMaker ? item.takerAbbr : item.makerAbbr;
      }

      if (sellCoinFilter != null && (sellCoinFilter != sellCoin)) {
        isMatched = false;
      }
      if (receiveCoinFilter != null && (receiveCoinFilter != receiveCoin)) {
        isMatched = false;
      }

      if (isMatched) filtered.add(item);
    }

    return filtered;
  }

  Widget _buildPagination(List<dynamic> orderSwaps) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Pagination(
        currentPage: _currentPage,
        total: orderSwaps.length,
        perPage: _perPage,
        onChanged: (int newPage) {
          setState(() => _currentPage = newPage);
          _scrollCtrl.jumpTo(0);
        },
      ),
    );
  }
}
