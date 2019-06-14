import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';
import 'package:komodo_dex/screens/dex/trade/trade_new_page.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';

class SwapPage extends StatefulWidget {
  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 3, vsync: this);

    swapBloc.outIndexTab.listen((onData) {
      tabController.index = onData;
    });
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
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Center(
                child: Text(
              AppLocalizations.of(context).exchangeTitle,
              style: Theme.of(context).textTheme.subtitle,
            )),
            bottom: PreferredSize(
              preferredSize: new Size(200.0, 70.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                child: Container(
                  height: 40,
                  
                  decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      border: new Border.all(color: Colors.grey, width: 1)),
                  child: TabBar(
                    labelPadding: EdgeInsets.symmetric(horizontal: 16),
                    indicator: CustomTabIndicator(context: context),
                    controller: tabController,
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context).create.toUpperCase(),
                      ),
                      Tab(
                          text: AppLocalizations.of(context)
                              .history
                              .toUpperCase()),
                      Tab(
                          text:
                              AppLocalizations.of(context).orders.toUpperCase())
                    ],
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          body: Builder(builder: (context) {
            return TabBarView(
              controller: tabController,
              children: <Widget>[
                TradeNewPage(
                  mContext: context,
                ),
                SwapHistory(),
                OrdersPage(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
