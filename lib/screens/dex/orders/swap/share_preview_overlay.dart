import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../localizations.dart';

class SharePreviewOverlay extends ModalRoute<void> {
  SharePreviewOverlay(this.file);

  final File file;

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.9);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => Navigator.of(context).pop(),
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 70, 10, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Image.file(file),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.closePreview),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
