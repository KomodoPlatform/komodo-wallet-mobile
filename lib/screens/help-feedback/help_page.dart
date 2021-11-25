import 'package:flutter/material.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/help-feedback/support_channel_item.dart';
import 'package:komodo_dex/widgets/html_parser.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  AppLocalizations local;
  List<dynamic> data;

  @override
  Widget build(BuildContext context) {
    local ??= AppLocalizations.of(context);
    data ??= <dynamic>[
      {
        'q': local.question_1,
        'a': Text(
          local.answer_1,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_2,
        'a': Text(
          local.answer_2,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_3,
        'a': HtmlParser(
          local.answer_3,
          textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.w300,
                height: 1.3,
                fontSize: 15,
              ),
          linkStyle: const TextStyle(
            color: Colors.blue,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_4,
        'a': Text(
          local.answer_4,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_5,
        'a': Text(
          local.answer_5,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
      <String, dynamic>{
        'q': local.question_6,
        'a': _getSupportAnswer(),
        'isExpanded': false,
      },
      {
        'q': local.question_7,
        'a': Text(
          local.answer_7,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_8,
        'a': Text(
          local.answer_8,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_9,
        'a': HtmlParser(
          local.answer_9,
          textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.w300,
                height: 1.3,
                fontSize: 15,
              ),
          linkStyle: const TextStyle(
            color: Colors.blue,
          ),
        ),
        'isExpanded': false,
      },
      {
        'q': local.question_10,
        'a': Text(
          local.answer_10,
          style: const TextStyle(
            height: 1.3,
            fontSize: 15,
          ),
        ),
        'isExpanded': false,
      },
    ];

    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).helpTitle),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: ListView(
          padding: EdgeInsets.only(bottom: 56),
          children: <Widget>[
            _buildLinks(),
            _buildFAQ(),
          ],
        ),
      ),
    );
  }

  dynamic _getSupportAnswer() {
    final List<SupportChannel> channels = appConfig.supportChannels;
    if (channels == null || channels.isEmpty) return null;

    final String name = channels[0].title ?? channels[0].subtitle;
    if (name == null) return null;

    return HtmlParser(
      local.answer_6(name, channels[0].link ?? ''),
      textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
            fontWeight: FontWeight.w300,
            height: 1.3,
            fontSize: 15,
          ),
      linkStyle: const TextStyle(
        color: Colors.blue,
      ),
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
          child: Text(
            AppLocalizations.of(context).faqTitle + ':',
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              data[index]['isExpanded'] = !isExpanded;
            });
          },
          children: data
              .where((dynamic item) => item['a'] != null)
              .map((dynamic item) {
            return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(item['q']),
                );
              },
              body: Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: item['a']),
              isExpanded: item['isExpanded'],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLinks() {
    final List<SupportChannel> channels = appConfig.supportChannels;
    if (channels == null || channels.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 20, 10),
          child: Text(
            AppLocalizations.of(context).support + ':',
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
          child: Text(
            AppLocalizations.of(context).supportLinksDesc,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.width / 2,
          ),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              children: channels.map((SupportChannel channel) {
                return SupportChannelItem(channel);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
