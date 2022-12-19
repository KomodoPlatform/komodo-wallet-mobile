import 'package:flutter/material.dart';
import '../../../../../localizations.dart';
import '../../../../../utils/utils.dart';

class SuccessStep extends StatefulWidget {
  const SuccessStep({Key key, this.txHash}) : super(key: key);

  final String txHash;

  @override
  _SuccessStepState createState() => _SuccessStepState();
}

class _SuccessStepState extends State<SuccessStep> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () => copyToClipBoard(context, widget.txHash),
              child: Column(
                children: <Widget>[
                  Text(AppLocalizations.of(context).success),
                  const SizedBox(
                    height: 16,
                  ),
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).hintColor,
                    size: 60,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
