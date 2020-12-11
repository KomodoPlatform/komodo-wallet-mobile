import 'package:flutter/material.dart';

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
          'Current value:',
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 4),
        Text(widget.currentValue),
        SizedBox(height: 12),
        Text(
          'New value:',
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 4),
        Text(widget.newValue),
        SizedBox(height: 12),
        if (merging) _buildMergingField(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: merging
              ? <Widget>[
                  RaisedButton(
                    child: const Text('Save merged'),
                    onPressed: () => widget.onMerge(mergedValueController.text),
                  ),
                  FlatButton(
                    child: const Text('Back'),
                    onPressed: () {
                      setState(() {
                        merging = false;
                      });
                    },
                  ),
                ]
              : <Widget>[
                  RaisedButton(
                    child: const Text('Merge'),
                    onPressed: () {
                      setState(() {
                        merging = true;
                      });
                    },
                  ),
                  RaisedButton(
                    child: const Text('Skip'),
                    onPressed: widget.onSkip,
                  ),
                  RaisedButton(
                    child: const Text('Overwrite'),
                    onPressed: widget.onOverwrite,
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
          'Merged Value:',
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 4),
        TextField(
          controller: mergedValueController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
