import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

abstract class AuthenticationGuards {
  static BeamGuard authenticated() {
    return BeamGuard(
      pathPatterns: ['*'],
      check: (context, location) {
        // TODO! Implement authentication check after auth bloc
        return true;
      },
    );
  }
}
