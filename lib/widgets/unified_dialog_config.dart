import 'package:flutter/material.dart';

class UnifiedDialogConfig {
  static const contentPadding = EdgeInsets.fromLTRB(24, 16, 24, 16);
  static const titlePadding = EdgeInsets.fromLTRB(24, 24, 24, 0);
  static const titlePaddingEmpty = EdgeInsets.all(0);
  static const verticalSpacing = SizedBox(height: 16);

  static TextStyle getButtonTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.button.copyWith(color: Colors.white);
}
