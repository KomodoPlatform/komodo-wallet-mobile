import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/orders/filters/filters.dart';
import 'package:komodo_dex/screens/dex/orders/swap/build_item_swap.dart';
import 'package:komodo_dex/widgets/pagination.dart';

class SwapHistory extends StatefulWidget {
  const SwapHistory({
    this.showFilters,
    this.activeFilters,
    this.onFiltersChange,
  });

  final bool showFilters;
  final Function(ActiveFilters) onFiltersChange;
  final ActiveFilters activeFilters;

  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  final _scrollCtrl = ScrollController();
  int _currentPage = 1;
  final int _perPage = 25;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: swapMonitor.swaps,
        builder:
            (BuildContext context, AsyncSnapshot<Iterable<Swap>> snapshot) {
          final List<Swap> swaps = snapshot.data.toList();

          swaps.removeWhere((Swap swap) =>
              swap.result.myInfo == null ||
              (swap.status != Status.SWAP_FAILED &&
                  swap.status != Status.SWAP_SUCCESSFUL &&
                  swap.status != Status.TIME_OUT));

          final List<Swap> swapsFiltered = _filter(swaps);

          if (snapshot.data != null &&
              swapsFiltered.isEmpty &&
              snapshot.connectionState == ConnectionState.active) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noSwaps,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          } else if (snapshot.data != null && swapsFiltered.isNotEmpty) {
            final int start = (_currentPage - 1) * _perPage;
            int end = start + _perPage;
            if (end > swapsFiltered.length) end = swapsFiltered.length;
            final List<Widget> swapsWidget = swapsFiltered
                .map((Swap swap) => BuildItemSwap(context: context, swap: swap))
                .toList()
                .sublist(start, end);

            return SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showFilters) _buildFilters(swaps),
                  _buildPagination(swapsFiltered),
                  ...swapsWidget,
                  _buildPagination(swapsFiltered),
                  SizedBox(height: 10),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _buildFilters(List<Swap> swaps) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Theme.of(context).highlightColor))),
        padding: EdgeInsets.fromLTRB(12, 12, 4, 16),
        child: Filters(
          items: swaps,
          activeFilters: widget.activeFilters,
          onChange: (ActiveFilters filters) {
            widget.onFiltersChange(filters);
          },
        ),
      ),
    );
  }

  List<Swap> _filter(List<Swap> unfiltered) {
    final List<Swap> filtered = [];
    final String sellCoinFilter = widget.activeFilters?.sellCoin;
    final String receiveCoinFilter = widget.activeFilters?.receiveCoin;

    for (Swap item in unfiltered) {
      String sellCoin;
      String receiveCoin;
      bool isMatched = true;

      sellCoin = item.isMaker ? item.makerAbbr : item.takerAbbr;
      receiveCoin = item.isMaker ? item.takerAbbr : item.makerAbbr;

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

  Widget _buildPagination(List<dynamic> swaps) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Pagination(
        currentPage: _currentPage,
        total: swaps.length,
        perPage: _perPage,
        onChanged: (int newPage) {
          setState(() => _currentPage = newPage);
          _scrollCtrl.jumpTo(0);
        },
      ),
    );
  }
}
