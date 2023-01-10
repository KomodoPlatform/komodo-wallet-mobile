import 'dart:io';
import 'package:flutter/material.dart';

class PageTransition<T> extends PageRouteBuilder<T> {
  final Widget child;

  final PageTransitionsBuilder matchingBuilder;

  final BuildContext ctx;

  /// Optional inherit theme
  final bool inheritTheme;

  PageTransition({
    Key key,
    @required this.child,
    this.ctx,
    this.inheritTheme = false,
    this.matchingBuilder = const CupertinoPageTransitionsBuilder(),
    RouteSettings settings,
  })  : assert(inheritTheme ? ctx != null : true,
            "'ctx' cannot be null when 'inheritTheme' is true, set ctx: context"),
        super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return inheritTheme ? InheritedTheme.captureAll(ctx, child) : child;
          },
          settings: settings,
          maintainState: true,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (Platform.isIOS) {
      var fade = FadeTransition(opacity: animation, child: child);
      return matchingBuilder.buildTransitions(
          this, context, animation, secondaryAnimation, fade);
    }
    return FadeTransition(opacity: animation, child: child);
  }
}
