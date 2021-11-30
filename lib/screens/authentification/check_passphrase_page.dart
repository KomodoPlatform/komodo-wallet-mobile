import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/check_passphrase_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/create_password_page.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class CheckPassphrasePage extends StatefulWidget {
  const CheckPassphrasePage({Key key, this.seed}) : super(key: key);

  final String seed;

  @override
  _CheckPassphrasePageState createState() => _CheckPassphrasePageState();

  bool checkSeedWord(WordData wordToCheck) {
    return wordToCheck.word == checkPassphraseBloc.word;
  }
}

class _CheckPassphrasePageState extends State<CheckPassphrasePage> {
  List<Widget> wordsWidget = <Widget>[];
  List<WordData> wordsDataRandom = <WordData>[];
  int stepper = 0;

  @override
  void initState() {
    checkPassphraseBloc.setIsWordGood(false);
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).checkSeedPhrase),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: <Widget>[
          Text(
            AppLocalizations.of(context).checkSeedPhraseTitle,
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).checkSeedPhraseInfo,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 48),
          wordsWidget[stepper],
          const SizedBox(height: 16),
          StreamBuilder<bool>(
              initialData: checkPassphraseBloc.isWordGood,
              stream: checkPassphraseBloc.outIsWordGoodLogin,
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
      checkPassphraseBloc.setIsResetText(true);
      if (stepper == 2) {
        Navigator.pushReplacement<dynamic, dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => CreatePasswordPage(
                    seed: widget.seed,
                  )),
        );
      } else {
        checkPassphraseBloc.setIsWordGood(false);
        setState(() {
          stepper += 1;
        });
      }
    }
  }
}

class SeedRandom extends StatefulWidget {
  const SeedRandom({Key key, this.data}) : super(key: key);

  final WordData data;

  @override
  _SeedRandomState createState() => _SeedRandomState();
}

class _SeedRandomState extends State<SeedRandom> {
  List<String> _buildListSeeds() {
    final List<String> words = [widget.data.word];

    while (words.length < 4) {
      final String word = getRandomWord();
      if (!words.contains(word)) words.add(word);
    }

    words.shuffle();

    return words;
  }

  Widget _buildSeedWord(String word) {
    return ElevatedButton(
        onPressed: () {
          _controller.text = word;

          checkPassphraseBloc.setWord(_controller.text);
          checkPassphraseBloc.setIsWordGood(
              const CheckPassphrasePage().checkSeedWord(widget.data));
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(word));
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context)
              .checkSeedPhraseSubtile((widget.data.index + 1).toString()),
          key: const Key('which-word'),
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          runSpacing: 8,
          spacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: _buildListSeeds().map(_buildSeedWord).toList(),
        ),
        const SizedBox(
          height: 8,
        ),
        StreamBuilder<bool>(
            initialData: checkPassphraseBloc.isResetText,
            stream: checkPassphraseBloc.outIsResetTextLogin,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data) {
                _controller.text = '';
              }
              return TextField(
                key: const Key('which-word-field'),
                controller: _controller,
                onChanged: (String text) {
                  checkPassphraseBloc.setWord(text);
                  checkPassphraseBloc.setIsWordGood(
                      const CheckPassphrasePage().checkSeedWord(widget.data));
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .checkSeedPhraseHint((widget.data.index + 1).toString()),
                ),
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
