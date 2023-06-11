import 'package:flutter/material.dart';
import '../../localizations.dart';
import '../../utils/utils.dart';
import '../../widgets/secondary_button.dart';

class ViewSeed extends StatelessWidget {
  const ViewSeed({this.seed, this.context});

  final String seed;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).seedPhrase,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 24, right: 16, left: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      seed,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SecondaryButton(
                        text: AppLocalizations.of(context).exportButton,
                        onPressed: () {
                          shareText(seed);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
