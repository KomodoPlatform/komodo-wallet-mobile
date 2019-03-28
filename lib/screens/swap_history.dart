import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/swap.dart';

class SwapHistory extends StatefulWidget {
  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  @override
  void initState() {
    swapHistoryBloc.updateSwap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length == 0) {
            return Center(
              child: Text("No Swaps", style: Theme.of(context).textTheme.body2,),
            );
          }
          if (snapshot.hasData && snapshot.data.length > 0) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Swap swap = snapshot.data[index];
                return Card(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      Text(swap.status.toString()),
                      Text(swap.result.uuid),
                    ],
                  ));
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
