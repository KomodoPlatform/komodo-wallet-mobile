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
  return bip39.generateMnemonic();
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
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          title: Text(AppLocalizations.of(context).newAccountUpper),
        ),
        body: ListView(
          key: const Key('new-account-scrollable'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          children: <Widget>[
            const SizedBox(height: 32),
            _buildTitle(),
            const SizedBox(height: 64),
            _buildSeedGenerator(),
            SizedBox(height: 32),
            _buildWarningSaveSeed(),
            SizedBox(height: 32),
            _buildNextButton(),
          ],
        ));
  }

  Widget _buildTitle() {
    return Text(
      AppLocalizations.of(context).seedPhraseTitle,
      style: Theme.of(context).textTheme.headline6,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSeedGenerator() {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: Theme.of(context).errorColor),
      ),
      tileColor: Theme.of(context).errorColor.withOpacity(0.15),
      contentPadding: EdgeInsets.all(8),
      leading: IconButton(
        key: const Key('seed-refresh'),
        color: Theme.of(context).errorColor,
        icon: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            seed = getSeed();
          });
        },
      ),
      title: Text(
        seed,
        key: const Key('seed-phrase'),
        style: Theme.of(context)
            .textTheme
            .bodyText2
            .copyWith(color: Theme.of(context).errorColor),
        textAlign: TextAlign.center,
      ),
      trailing: IconButton(
          key: const Key('seed-copy'),
          onPressed: () => Clipboard.setData(ClipboardData(text: seed)),
          color: Theme.of(context).errorColor,
          icon: Icon(Icons.content_copy)),
    );
  }

  Widget _buildWarningSaveSeed() {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.pink,
                Colors.red.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          height: 45,
          width: 45,
          child: const Center(
            child: Icon(
              Icons.warning,
              color: Colors.white,
            ),
          ),
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
                style: Theme.of(context).textTheme.subtitle2,
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                AppLocalizations.of(context).recommendSeedMessage,
                style: Theme.of(context).textTheme.bodyText2,
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNextButton() {
    return PrimaryButton(
      key: const Key('create-seed-button'),
      text: AppLocalizations.of(context).next,
      onPressed: () => Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => CheckPassphrasePage(
            seed: seed,
          ),
        ),
      ),
    );
  }
}
