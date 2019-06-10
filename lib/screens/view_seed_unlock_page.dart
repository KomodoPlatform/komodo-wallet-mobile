import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/lock_screen.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class ViewSeedUnlockPage extends StatefulWidget {
  @override
  _ViewSeedUnlockPageState createState() => _ViewSeedUnlockPageState();
}

class _ViewSeedUnlockPageState extends State<ViewSeedUnlockPage> {
  bool passwordSuccess = false;
  String seed;

  @override
  Widget build(BuildContext context) {
    return LockScreen(
          child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: Text(AppLocalizations.of(context).viewSeed.toUpperCase()),
          centerTitle: true,
          actions: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(AppLocalizations.of(context).done)),
              ),
            )
          ],
        ),
        body: Builder(builder: (context) {
          return passwordSuccess
              ? ViewSeed(
                  seed: seed,
                  context: context,
                )
              : UnlockPassword(
                icon: SvgPicture.asset("assets/seed_logo.svg"),
                  onSuccess: (data) {
                    setState(() {
                      seed = data;
                      passwordSuccess = true;
                    });
                  },
                  onError: (data) {
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      duration: Duration(seconds: 2),
                      backgroundColor: Theme.of(context).errorColor,
                      content: new Text(data),
                    ));
                    print("error password");
                  },
                );
        }),
      ),
    );
  }
}

class ViewSeed extends StatefulWidget {
  final String seed;
  final BuildContext context;

  ViewSeed({this.seed, this.context});

  @override
  _ViewSeedState createState() => _ViewSeedState();
}

class _ViewSeedState extends State<ViewSeed> {
  List<Widget> seedWord = new List<Widget>();

  @override
  void initState() {
    int i = 1;
    widget.seed.split(" ").forEach((word) {
      seedWord.add(RichText(
        text: TextSpan(
            style:
                Theme.of(widget.context).textTheme.body1.copyWith(fontSize: 22),
            children: [
              TextSpan(
                  text: i.toString().padLeft(2, '0'),
                  style: Theme.of(widget.context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme.of(widget.context).accentColor)),
              TextSpan(
                  text: '. $word',
                  style: Theme.of(widget.context).textTheme.body1)
            ]),
      ));
      i++;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.only(top: 50, bottom: 32, right: 16, left: 16),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: GridView.count(
            shrinkWrap: true,
            primary: false,
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            children: seedWord,
            childAspectRatio: 4.0,
            crossAxisSpacing: 4.0,
          ),
        ),
        SizedBox(height: 24,),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SecondaryButton(
              text: AppLocalizations.of(context).clipboardCopy,
              onPressed: (){
                copyToClipBoard(context, widget.seed);
              },
            ),
          ),
        )
      ],
    );
  }
}

class UnlockPassword extends StatefulWidget {
  final Function(String) onSuccess;
  final Function(String) onError;
  final SvgPicture icon;

  UnlockPassword({this.onSuccess, this.onError, this.icon});

  @override
  _UnlockPasswordState createState() => _UnlockPasswordState();
}

class _UnlockPasswordState extends State<UnlockPassword> {
  TextEditingController controller = new TextEditingController();
  bool isContinueEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        SizedBox(height: 32),
        widget.icon,
        SizedBox(height: 100),
        Text(
          AppLocalizations.of(context).enterpassword,
          style: Theme.of(context).textTheme.body1,
        ),
        SizedBox(height: 8),
        TextField(
            maxLength: 40,
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (data) {
              _checkPassword(data);
            },
            onChanged: (data) {
              setState(() {
                data.isNotEmpty
                    ? isContinueEnabled = true
                    : isContinueEnabled = false;
              });
            },
            autocorrect: false,
            obscureText: true,
            enableInteractiveSelection: true,
            style: Theme.of(context).textTheme.body1,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColorLight)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                hintStyle: Theme.of(context).textTheme.body2,
                labelStyle: Theme.of(context).textTheme.body1,
                hintText: AppLocalizations.of(context).hintCurrentPassword,
                labelText: null)),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: PrimaryButton(
            text: AppLocalizations.of(context).checkSeedPhraseButton1,
            onPressed: isContinueEnabled
                ? () => _checkPassword(controller.text)
                : null,
          ),
        )
      ],
    );
  }

  _checkPassword(String data) async {
    var entryptionTool = new EncryptionTool();
    String seed = await entryptionTool.readData(KeyEncryption.SEED, walletBloc.currentWallet, data);
    if (seed != null) {
      widget.onSuccess(seed);
    } else {
      widget.onError(AppLocalizations.of(context).wrongPassword);
    }
  }
}
