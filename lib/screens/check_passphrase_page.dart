import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/check_passphrase_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/create_password_page.dart';
import 'package:komodo_dex/widgets/custom_textfield.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class CheckPassphrasePage extends StatefulWidget {
  final String seed;

  CheckPassphrasePage({this.seed});

  @override
  _CheckPassphrasePageState createState() => _CheckPassphrasePageState();

  bool checkSeedWord(WordData wordToCheck) {
    return wordToCheck.word == checkPassphrasePage.word;
  }
}

class _CheckPassphrasePageState extends State<CheckPassphrasePage> {
  List<Widget> wordsWidget = List<Widget>();
  List<WordData> wordsDataRandom = List<WordData>();
  int stepper = 0;
  TextEditingController _controller;

  @override
  void initState() {
    checkPassphrasePage.setIsWordGood(false);
    List<WordData> wordsData = new List<WordData>();
    List<String> wordsSeed = widget.seed.split(" ");

    int i = 0;
    wordsSeed.forEach((word) {
      wordsData.add(WordData(word: word, index: i));
      i++;
    });
    final _random = new Random();

    for (var i = 0; i < 3; i++) {
      int res = _random.nextInt(wordsData.length);
      wordsWidget.add(SeedRandom(data: wordsData[res]));
      wordsDataRandom.add(wordsData[res]);
      wordsData.removeAt(res);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).checkSeedPhrase),
      ),
      body: ListView(
        padding: const EdgeInsets.all(32.0),
        children: <Widget>[
          Text(
            AppLocalizations.of(context).checkSeedPhraseTitle,
            style: Theme.of(context).textTheme.title,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            AppLocalizations.of(context).checkSeedPhraseInfo,
            style: Theme.of(context).textTheme.body2,
          ),
          SizedBox(
            height: 48,
          ),
          wordsWidget[stepper],
          SizedBox(
            height: 16,
          ),
          StreamBuilder<bool>(
              initialData: checkPassphrasePage.isWordGood,
              stream: checkPassphrasePage.outIsWordGoodLogin,
              builder: (context, snapshot) {
                return PrimaryButton(
                  text: AppLocalizations.of(context).checkSeedPhraseButton1,
                  onPressed: snapshot.data ? _onPressedNext : null,
                );
              }),
          SizedBox(
            height: 16,
          ),
          SecondaryButton(
            text: AppLocalizations.of(context).checkSeedPhraseButton2,
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  _onPressedNext() {
    if (widget.checkSeedWord(wordsDataRandom[stepper])) {
      checkPassphrasePage.setIsResetText(true);
      if (stepper == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CreatePasswordPage(
                    seed: widget.seed,
                  )),
        );
      } else {
        checkPassphrasePage.setIsWordGood(false);
        setState(() {
          stepper += 1;
        });
      }
    }
  }
}

class SeedRandom extends StatefulWidget {
  WordData data;

  SeedRandom({this.data});
  @override
  _SeedRandomState createState() => _SeedRandomState();
}

class _SeedRandomState extends State<SeedRandom> {
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context)
              .checkSeedPhraseSubtile((widget.data.index + 1).toString()),
          style: Theme.of(context).textTheme.body1,
        ),
        SizedBox(
          height: 8,
        ),
        StreamBuilder<bool>(
            initialData: checkPassphrasePage.isResetText,
            stream: checkPassphrasePage.outIsResetTextLogin,
            builder: (context, snapshot) {
              if (snapshot.data) {
                _controller.text = "";
              }
              return CustomTextField(
                controller: _controller,
                onChanged: (text) {
                  checkPassphrasePage.setWord(text);
                  checkPassphrasePage.setIsWordGood(
                      CheckPassphrasePage().checkSeedWord(widget.data));
                },
                hintText: AppLocalizations.of(context)
                    .checkSeedPhraseHint((widget.data.index + 1).toString()),
              );
            }),
      ],
    );
  }
}

class WordData {
  int index;
  String word;

  WordData({this.index, this.word});
}
