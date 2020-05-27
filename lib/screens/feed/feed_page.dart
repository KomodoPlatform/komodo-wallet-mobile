import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/media_bloc.dart';
import 'package:komodo_dex/screens/feed/devops/devops_tab.dart';
import 'package:komodo_dex/screens/feed/issues/issues_tab.dart';
import 'package:komodo_dex/screens/feed/news/news_tab.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';
import 'package:komodo_dex/utils/log.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with SingleTickerProviderStateMixin {
  TabController _controllerTabs;
  @override
  void initState() {
    _controllerTabs = TabController(length: 3, vsync: this);
    _controllerTabs.addListener(_getIndex);
    mediaBloc.getArticles();
    super.initState();
  }

  @override
  void dispose() {
    _controllerTabs.dispose();
    super.dispose();
  }

  void _getIndex() {
    Log.println('media_page:38', _controllerTabs.index);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildAppBar() {
      final bool _isSmallScreen = MediaQuery.of(context).size.height < 680;

      final Widget _tabsPanel = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              border: Border.all(color: Colors.grey, width: 1)),
          child: TabBar(
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicator: CustomTabIndicator(context: context),
            controller: _controllerTabs,
            tabs: <Widget>[
              Tab(text: 'News'.toUpperCase()), // TODO(yurii): localization
              Tab(text: 'DevOps'.toUpperCase()), // TODO(yurii): localization
              Tab(text: 'Progress'.toUpperCase()), // TODO(yurii): localization
            ],
          ),
        ),
      );

      return _isSmallScreen
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AppBar(
                flexibleSpace: SafeArea(
                    child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    _tabsPanel,
                  ],
                )),
              ),
            )
          : AppBar(
              title: Center(
                  child: Text(
                'Feed'.toUpperCase(), // TODO(yurii): localization
                style: Theme.of(context).textTheme.subtitle,
              )),
              /* bottom: PreferredSize(
                preferredSize: const Size(200.0, 70.0),
                child: Column(
                  children: <Widget>[
                    _tabsPanel,
                    const SizedBox(height: 15),
                  ],
                ),
              ) */);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _controllerTabs,
        children: <Widget>[
          NewsTab(),
          DevOpsTab(),
          IssuesTab(),
        ],
      ),
    );
  }
}

