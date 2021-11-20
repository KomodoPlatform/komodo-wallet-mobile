import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/check_passphrase_page.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({Key key}) : super(key: key);

  @override
  _NewAccountPageState createState() => _NewAccountPageState();
}

String getSeed() {
  int i = 0;
  String seed = '';
  while (i == 0) {
    seed = bip39.generateMnemonic();
    i = 1;
    for (String word in seed.split(' ')) {
      try {
        seed
            .split(' ')
            .singleWhere((String seedelement) => seedelement == word);
      } catch (e) {
        if (e.toString().contains('Too many elements')) {
          i = 0;
        }
      }
    }
  }
  return seed;
}

class _NewAccountPageState extends State<NewAccountPage> {
  String seed = '';

  @override
  void initState() {
    seed = getSeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).newAccountUpper),
        ),
        body: ListView(
          key: const Key('new-account-scrollable'),
          children: <Widget>[
            _buildTitle(),
            _buildSeedGenerator(),
            _buildWarningSaveSeed(),
            _buildNextButton(),
          ],
        ));
  }

  Widget _buildTitle() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 56,
        ),
        Text(
          AppLocalizations.of(context).seedPhraseTitle,
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 56,
        ),
      ],
    );
  }

  Widget _buildSeedGenerator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.red.withOpacity(0.15),
              border: Border.all(color: Colors.red)),
          padding: const EdgeInsets.all(8.0),
          // height: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                key: const Key('seed-refresh'),
                splashRadius: 24,
                color: Theme.of(context).errorColor,
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    seed = getSeed();
                  });
                },
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                  child: Text(
                seed,
                key: const Key('seed-phrase'),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).errorColor),
                textAlign: TextAlign.center,
              )),
              const SizedBox(
                width: 6,
              ),
              IconButton(
                  splashRadius: 24,
                  key: const Key('seed-copy'),
                  onPressed: () => Clipboard.setData(ClipboardData(text: seed)),
                  color: Theme.of(context).errorColor,
                  icon: Icon(Icons.content_copy)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningSaveSeed() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.pink,
                    Colors.red.withOpacity(0.4),
                  ],
                )),
                height: 45,
                width: 45,
                child: const Center(
                  child: Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                )),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).getBackupPhrase,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  AppLocalizations.of(context).recommendSeedMessage,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: SizedBox(
          width: double.infinity,
          height: 50,
          child: PrimaryButton(
            text: AppLocalizations.of(context).next,
            onPressed: () {
              Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => CheckPassphrasePage(
                          seed: seed,
                        )),
              );
            },
          )),
    );
  }
}
