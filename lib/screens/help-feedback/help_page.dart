import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:komodo_dex/screens/help-feedback/feedback_page.dart';
import 'package:archive/archive.dart' as arch;
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  // TODO(yurii): localization
  final data = [
    {
      'q': 'Do you store my private keys?',
      'a': 'No! AtomicDEX is non-custodial. We never store any sensitive'
          ' data, including your private keys, seed phrases, or PIN. They'
          ' never leave your device.'
          ' You are in full control of your assets.',
      'isExpanded': false,
    },
    {
      'q': 'Do you provide user support?',
      'a': 'Yes! Unlike most open source blockchain projects,'
          ' AtomicDEX offers 24/7 support. Join our Discord,'
          ' we are happy to help!',
      'isExpanded': false,
    },
    {
      'q': 'Do you have country restrictions?',
      'a': 'No! AtomicDEX is fully decentralized. It is not possible'
          ' to limit user access by any third party.',
      'isExpanded': false,
    },
    {
      'q': 'Who is behind AtomicDEX?',
      'a': 'AtomicDEX is developed by the Komodo team. Komodo is one'
          ' of the most established blockchain projects working on innovative'
          ' solutions like atomic swaps, Delayed Proof-of-Work, and an'
          ' interoperable multi-chain architecture.',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO(yurii): localization
        title: const Text('Help and Feedback'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFAQ(),
            _buildLinks(),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Text(
            // TODO(yurii): localization
            'Report a problem:',
            style: Theme.of(context).textTheme.subtitle,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Text(
            'If you think you\'ve found a technical problem with'
            ' the atomicDEX app, you can report it and get support'
            ' from our team.',
            style: Theme.of(context).textTheme.body2,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
          child: RaisedButton(
            // TODO(yurii): localization
            child: const Text('Get support'),
            onPressed: () async {
              final Email email = Email(
                body: 'Email body',
                subject: 'Email subject',
                recipients: ['example@example.com'],
                cc: ['cc@example.com'],
                bcc: ['bcc@example.com'],
                //attachmentPaths: ['/path/to/attachment.zip'],
                isHTML: false,
              );

              await FlutterEmailSender.send(email);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Text(
            // TODO(yurii): localization
            'Frequently Asked Questions:',
            style: Theme.of(context).textTheme.subtitle,
          ),
        ),
        ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              data[index]['isExpanded'] = !isExpanded;
            });
          },
          children: data.map((item) {
            return ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(item['q']),
                );
              },
              body: Container(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                child: Text(
                  item['a'],
                  style: const TextStyle(height: 1.3),
                ),
              ),
              isExpanded: item['isExpanded'],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
            bottom: 10,
          ),
          child: Text(
            // TODO(yurii): localization
            'Connect with us also on:',
            style: Theme.of(context).textTheme.subtitle,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
          ),
          child: Wrap(
            children: <Widget>[
              _buildSocialPlatform(
                text: 'DISCORD',
                link: 'http://komodoplatform.com/discord',
                icon: SizedBox(
                  width: 60,
                  child: Image.asset('assets/discord_logo.png'),
                ),
              ),
              _buildSocialPlatform(
                text: 'Twitter',
                link: 'https://twitter.com/KomodoPlatform',
                icon: Container(
                  width: 60,
                  padding: const EdgeInsets.only(
                      left: 7, right: 7, top: 5, bottom: 8),
                  child: Image.asset('assets/twitter_logo.png'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPlatform({
    Widget icon,
    String text,
    String link,
  }) {
    return FlatButton(
      onPressed: () {
        launchURL(link);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            icon,
            Text(text),
          ],
        ),
      ),
    );
  }
}
