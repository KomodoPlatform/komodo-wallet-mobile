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
  String seed = "";

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

  _buildTitle() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 56,
        ),
        Text(
          AppLocalizations.of(context).seedPhraseTitle,
          style: Theme.of(context).textTheme.title,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 56,
        ),
      ],
    );
  }

  _buildSeedGenerator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.red.withOpacity(0.15),
              border: Border.all(color: Colors.red)),
          padding: const EdgeInsets.all(8.0),
          // height: 100,
          child: Row(
            children: <Widget>[
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8)),
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
              SizedBox(
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
              SizedBox(
                width: 6,
              ),
              InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: seed));
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

  _buildWarningSaveSeed() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
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
          SizedBox(
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
                SizedBox(
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

  _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Container(
        width: double.infinity,
        height: 50,
        child: PrimaryButton(
          text: AppLocalizations.of(context).next,
            onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CheckPassphrasePage(seed: seed,)),
            );
          },
        )
      ),
    );
  }
}
