import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/orders/swap/build_item_swap.dart';
import 'package:komodo_dex/widgets/pagination.dart';

class SwapHistory extends StatefulWidget {
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

          if (snapshot.data != null &&
              swaps.isEmpty &&
              snapshot.connectionState == ConnectionState.active) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noSwaps,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          } else if (snapshot.data != null && swaps.isNotEmpty) {
            final int start = (_currentPage - 1) * _perPage;
            int end = start + _perPage;
            if (end > swaps.length) end = swaps.length;
            final List<Widget> swapsWidget = swaps
                .map((Swap swap) => BuildItemSwap(context: context, swap: swap))
                .toList()
                .sublist(start, end);

            return SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPagination(swaps),
                  ...swapsWidget,
                  _buildPagination(swaps),
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
