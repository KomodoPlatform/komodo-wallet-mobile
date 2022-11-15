import 'package:flutter/material.dart';

import '../../localizations.dart';

class OverwriteDialogContent extends StatefulWidget {
  const OverwriteDialogContent({
    this.currentValue,
    this.newValue,
    this.onSkip,
    this.onOverwrite,
    this.onMerge,
  });

  final String currentValue;
  final String newValue;
  final Function onSkip;
  final Function onOverwrite;
  final Function(String) onMerge;

  @override
  _OverwriteDialogContentState createState() => _OverwriteDialogContentState();
}

class _OverwriteDialogContentState extends State<OverwriteDialogContent> {
  final mergedValueController = TextEditingController();
  bool merging = false;

  @override
  void initState() {
    mergedValueController.text = '${widget.currentValue} + ${widget.newValue}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context).currentValue,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 4),
        Text(widget.currentValue),
        SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).newValue,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 4),
        Text(widget.newValue),
        SizedBox(height: 12),
        if (merging) _buildMergingField(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: merging
              ? <Widget>[
                  ElevatedButton(
                    onPressed: () => widget.onMerge(mergedValueController.text),
                    child: Text(AppLocalizations.of(context).saveMerged),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        merging = false;
                      });
                    },
                    child: Text(AppLocalizations.of(context).back),
                  ),
                ]
              : <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        merging = true;
                      });
                    },
                    child: Text(AppLocalizations.of(context).merge),
                  ),
                  ElevatedButton(
                    onPressed: widget.onSkip,
                    child: Text(AppLocalizations.of(context).skip),
                  ),
                  ElevatedButton(
                    onPressed: widget.onOverwrite,
                    child: Text(AppLocalizations.of(context).overwrite),
                  ),
                ],
        )
      ],
    );
  }

  Widget _buildMergingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context).mergedValue,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 4),
        TextField(
          controller: mergedValueController,
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
