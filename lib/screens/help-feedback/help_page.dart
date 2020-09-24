import 'package:flutter/material.dart';
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
      'q': 'How is trading on AtomicDEX different from trading on other DEXs?',
      'a': 'Other DEXs generally only allow you to trade assets that are based'
          ' on a single blockchain network, use proxy tokens, and'
          ' only allow placing a single order with the same funds.'
          '\n\nAtomicDEX enables you to natively trade across two different'
          ' blockchain networks without proxy tokens. You can also place multiple'
          ' orders with the same funds. For example, you can sell 0.1 BTC for'
          ' KMD, QTUM, or VRSC — the first order that fills automatically'
          ' cancels all other orders.',
      'isExpanded': false,
    },
    {
      'q': 'How long does each atomic swap take?',
      'a': 'Several factors determine the processing time for each swap.'
          ' The block time of the traded assets depends on each network'
          ' (Bitcoin typically being the slowest) Additionally, the user can'
          ' customize security preferences. For example,  (you can ask AtomicDEX'
          ' to consider a KMD transaction as final after just 3 confirmations'
          ' which makes the swap time shorter compared to waiting'
          ' for a notarization.',
      'isExpanded': false,
    },
    {
      'q': 'Do I need to be online for the duration of the swap?',
      'a': 'Yes. You must remain connected to the internet and have your app'
          ' running to successfully complete each atomic swap (very short breaks'
          ' in connectivity are usually fine). Otherwise, there is risk of trade'
          ' cancellation if you are a maker, and risk of loss of funds if you are'
          ' a taker. The atomic swap protocol requires both participants to stay'
          ' online and monitor the involved blockchains for'
          ' the process to stay atomic. ',
      'isExpanded': false,
    },
    {
      'q': 'How are the fees on atomicDEX calculated?',
      'a': 'There are two fee categories to consider when trading on AtomicDEX.\n\n'
          '1. AtomicDEX charges approximately 0.13% (1/777 of trading volume but'
          ' not lower than 0.0001) as the trading fee for taker orders, and maker'
          ' orders have zero fees.\n\n2. Both makers and takers will need to pay'
          ' normal network fees to the involved blockchains when making atomic'
          ' swap transactions.\n\nNetwork fees can vary greatly depending on'
          ' your selected trading pair.',
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
    {
      'q':
          'Is it possible to develop my own white-label exchange on AtomicDEX?',
      'a': 'Absolutely! You can read our developer documentation for more'
          ' details or contact us with your partnership inquiries. Have a specific'
          ' technical question? The AtomicDEX developer community'
          ' is always ready to help!',
      'isExpanded': false,
    },
    {
      'q': 'Which devices can I use AtomicDEX on?',
      'a': 'AtomicDEX is available for mobile on both Android and iPhone,'
          ' and for desktop on Windows, Mac, and Linux operating systems.',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO(yurii): localization
        title: const Text('Help and Support'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFAQ(),
            _buildLinks(),
          ],
        ),
      ),
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
          padding: const EdgeInsets.fromLTRB(15, 15, 20, 10),
          child: Text(
            // TODO(yurii): localization
            'Support:',
            style: Theme.of(context).textTheme.subtitle,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
          child: Text(
            'If you have any questions,'
            ' or think you\'ve found a technical problem with'
            ' the atomicDEX app, you can report it and get support'
            ' from our team.',
            style: Theme.of(context).textTheme.body2,
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width / 2,
          padding: const EdgeInsets.only(bottom: 20),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              children: <Widget>[
                _buildSocialPlatform(
                  title: 'DISCORD',
                  subtitle: 'Komodo #support',
                  link: 'http://komodoplatform.com/discord',
                  icon: SizedBox(
                    width: 60,
                    child: Image.asset('assets/discord_logo.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPlatform({
    Widget icon,
    String title,
    String subtitle,
    String link,
  }) {
    return FlatButton(
      onPressed: () {
        launchURL(link);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(subtitle),
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
