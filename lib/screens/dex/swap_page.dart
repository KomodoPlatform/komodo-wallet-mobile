
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:komodo_dex/screens/dex/trade/trade_new_page.dart';

class SwapPage extends StatefulWidget {
  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 2, vsync: this);
    if (swapHistoryBloc.isSwapsOnGoing) {
      tabController.index = 1;
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: SafeArea(
              child: AppBar(
                bottom: TabBar(
                  controller: tabController,
                  tabs: [
                    Tab(
                      text: AppLocalizations.of(context).create.toUpperCase(),
                    ),
                    Tab(
                        text:
                            AppLocalizations.of(context).history.toUpperCase())
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          body: TabBarView(
            controller: tabController,
            children: <Widget>[TradeNewPage(), SwapHistory()],
          ),
        ),
      ),
    );
  }
}