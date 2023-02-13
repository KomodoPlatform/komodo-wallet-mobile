import 'package:flutter/material.dart';

class CustomSimpleDialog extends StatelessWidget {
  const CustomSimpleDialog({
    Key? key,
    required this.children,
    this.title,
    this.hasHorizontalPadding = true,
    this.verticalButtons,
  }) : super(key: key);

  /// Same as the children you would use on SimpleDialog
  final List<Widget> children;

  /// The title widget, if any, keep it null for no title
  final Widget? title;

  /// Whether to use a big or small amount of horizontal padding
  final bool hasHorizontalPadding;

  /// The List of vertical button, if any, keep it null for no vertical buttons
  final List<Widget>? verticalButtons;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: hasHorizontalPadding
          ? EdgeInsets.fromLTRB(24, 16, 24, 16)
          : EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
      titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: title,
      children: [
        ...?children,
        ...?verticalButtons,
      ],
    );
  }
}
