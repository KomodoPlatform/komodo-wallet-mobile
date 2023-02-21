import 'package:flutter/material.dart';
import '../../../generic_blocs/swap_history_bloc.dart';
import '../../../localizations.dart';
import '../../../model/order.dart';
import '../../../model/swap.dart';
import '../../../model/swap_provider.dart';
import '../../dex/orders/filters/filters.dart';
import '../../dex/orders/swap/build_item_swap.dart';
import '../../../widgets/pagination.dart';

class SwapHistory extends StatefulWidget {
  const SwapHistory({
    this.scrollCtrl,
    this.showFilters,
    this.activeFilters,
    this.onFiltersChange,
  });

  final ScrollController? scrollCtrl;
  final bool? showFilters;
  final Function(ActiveFilters)? onFiltersChange;
  final ActiveFilters? activeFilters;

  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  int _currentPage = 1;
  final int _perPage = 25;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: swapMonitor.swaps,
        builder:
            (BuildContext context, AsyncSnapshot<Iterable<Swap>> snapshot) {
          final List<Swap> swaps = snapshot.data!.toList();

          swaps.removeWhere((Swap swap) =>
              swap.status != Status.SWAP_FAILED &&
              swap.status != Status.SWAP_SUCCESSFUL &&
              swap.status != Status.TIME_OUT);

          final List<Swap> swapsFiltered = _filter(swaps);

          if (snapshot.connectionState != ConnectionState.active) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final int start = (_currentPage - 1) * _perPage;
          int end = start + _perPage;
          if (end > swapsFiltered.length) end = swapsFiltered.length;
          final List<Widget> swapsWidget = swapsFiltered
              .map((Swap swap) => BuildItemSwap(context: context, swap: swap))
              .toList()
              .sublist(start, end);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            controller: widget.scrollCtrl,
            children: [
              if (widget.showFilters!) _buildFilters(swaps),
              if (swapsFiltered.isEmpty) ...{
                SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Center(
                      child: Text(AppLocalizations.of(context)!.noSwaps)),
                )
              },
              if (swapsFiltered.isNotEmpty) ...{
                _buildPagination(swapsFiltered),
                ...swapsWidget,
                _buildPagination(swapsFiltered),
                SizedBox(height: 10),
              },
            ],
          );
        });
  }

  Widget _buildFilters(List<dynamic> swaps) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 8, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Filters(
          items: swaps.cast<Swap>(),
          filter: _filter,
          showStatus: true,
          activeFilters: widget.activeFilters,
          onChange: (ActiveFilters filters) {
            setState(() => _currentPage = 1);
            widget.onFiltersChange!(filters);
          },
        ),
      ),
    );
  }

  List<Swap> _filter(List<Swap> unfiltered) {
    final List<Swap> filtered = [];
    final String? sellCoinFilter = widget.activeFilters?.sellCoin;
    final String? receiveCoinFilter = widget.activeFilters?.receiveCoin;
    final OrderType? typeFilter = widget.activeFilters?.type;
    final DateTime? startFilter = widget.activeFilters?.start;
    final DateTime? endFilter = widget.activeFilters?.end;
    final Status? statusFilter = widget.activeFilters?.status;

    for (Swap item in unfiltered) {
      bool isMatched = true;

      final String? sellCoin = item.isMaker ? item.makerAbbr : item.takerAbbr;
      final String? receiveCoin =
          item.isMaker ? item.takerAbbr : item.makerAbbr;
      final OrderType type = item.isMaker ? OrderType.MAKER : OrderType.TAKER;
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
          item.started?.timestamp ?? DateTime.now().millisecondsSinceEpoch);
      final Status? status = item.status;

      if (sellCoinFilter != null && (sellCoinFilter != sellCoin)) {
        isMatched = false;
      }
      if (receiveCoinFilter != null && (receiveCoinFilter != receiveCoin)) {
        isMatched = false;
      }
      if (typeFilter != null && (typeFilter != type)) isMatched = false;
      if (startFilter != null &&
          startFilter.millisecondsSinceEpoch > date.millisecondsSinceEpoch) {
        isMatched = false;
      }
      if (endFilter != null &&
          endFilter.millisecondsSinceEpoch < date.millisecondsSinceEpoch) {
        isMatched = false;
      }
      if (statusFilter != null && statusFilter != status) isMatched = false;

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
          widget.scrollCtrl!.jumpTo(0);
        },
      ),
    );
  }
}
