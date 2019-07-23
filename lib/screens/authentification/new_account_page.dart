import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/check_passphrase_page.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class NewAccountPage extends StatefulWidget {
  @override
  _NewAccountPageState createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  String seed = '';

  @override
  void initState() {
    seed = bip39.generateMnemonic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).newAccountUpper),
        ),
        body: Column(
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
          style: Theme.of(context).textTheme.title,
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
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  setState(() {
                    seed = bip39.generateMnemonic();
                  });
                },
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                  child: Text(
                seed,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              )),
              const SizedBox(
                width: 6,
              ),
              InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: seed));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.content_copy,
                      color: Colors.red,
                    ),
                  )),
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
                child: Center(
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
                      .body1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  AppLocalizations.of(context).recommendSeedMessage,
                  style: Theme.of(context).textTheme.body2,
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
      child: Container(
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
