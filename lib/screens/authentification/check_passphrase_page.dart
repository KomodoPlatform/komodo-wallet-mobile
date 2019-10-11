import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/check_passphrase_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/create_password_page.dart';
import 'package:komodo_dex/widgets/custom_textfield.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class CheckPassphrasePage extends StatefulWidget {
  const CheckPassphrasePage({this.seed});

  final String seed;

  @override
  _CheckPassphrasePageState createState() => _CheckPassphrasePageState();

  bool checkSeedWord(WordData wordToCheck) {
    return wordToCheck.word == checkPassphrasePage.word;
  }
}

class _CheckPassphrasePageState extends State<CheckPassphrasePage> {
  List<Widget> wordsWidget = <Widget>[];
  List<WordData> wordsDataRandom = <WordData>[];
  int stepper = 0;
  TextEditingController _controller;

  @override
  void initState() {
    checkPassphrasePage.setIsWordGood(false);
    final List<WordData> wordsData = <WordData>[];
    final List<String> wordsSeed = widget.seed.split(' ');

    int i = 0;
    for (String word in wordsSeed) {
      wordsData.add(WordData(word: word, index: i));
      i++;
    }
    final Random _random = Random();

    for (int i = 0; i < 3; i++) {
      final int res = _random.nextInt(wordsData.length);
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
          const SizedBox(
            height: 16,
          ),
          Text(
            AppLocalizations.of(context).checkSeedPhraseInfo,
            style: Theme.of(context).textTheme.body2,
          ),
          const SizedBox(
            height: 48,
          ),
          wordsWidget[stepper],
          const SizedBox(
            height: 16,
          ),
          StreamBuilder<bool>(
              initialData: checkPassphrasePage.isWordGood,
              stream: checkPassphrasePage.outIsWordGoodLogin,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return PrimaryButton(
                  text: AppLocalizations.of(context).checkSeedPhraseButton1,
                  onPressed: snapshot.data ? _onPressedNext : null,
                );
              }),
          const SizedBox(
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

  void _onPressedNext() {
    if (widget.checkSeedWord(wordsDataRandom[stepper])) {
      checkPassphrasePage.setIsResetText(true);
      if (stepper == 2) {
        Navigator.pushReplacement<dynamic, dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => CreatePasswordPage(
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
  const SeedRandom({this.data});

  final WordData data;

  @override
  _SeedRandomState createState() => _SeedRandomState();
}

class _SeedRandomState extends State<SeedRandom> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context)
              .checkSeedPhraseSubtile((widget.data.index + 1).toString()),
          style: Theme.of(context).textTheme.body1,
        ),
        const SizedBox(
          height: 8,
        ),
        StreamBuilder<bool>(
            initialData: checkPassphrasePage.isResetText,
            stream: checkPassphrasePage.outIsResetTextLogin,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data) {
                _controller.text = '';
              }
              return CustomTextField(
                controller: _controller,
                onChanged: (String text) {
                  checkPassphrasePage.setWord(text);
                  checkPassphrasePage.setIsWordGood(
                      const CheckPassphrasePage().checkSeedWord(widget.data));
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
  WordData({this.index, this.word});

  int index;
  String word;
}
