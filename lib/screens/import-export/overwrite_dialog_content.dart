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
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 4),
        Text(widget.currentValue),
        SizedBox(height: 12),
        Text(
          'New value:',
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
                    child: const Text('Save merged'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        merging = false;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ]
              : <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        merging = true;
                      });
                    },
                    child: const Text('Merge'),
                  ),
                  ElevatedButton(
                    onPressed: widget.onSkip,
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: widget.onOverwrite,
                    child: const Text('Overwrite'),
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
          style: Theme.of(context).textTheme.bodyText1,
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
