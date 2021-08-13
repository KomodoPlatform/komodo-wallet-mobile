import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/utils.dart';

class LanguageFlagIcon extends StatelessWidget {
  const LanguageFlagIcon({Key key, this.loc, this.size}) : super(key: key);

  final Locale loc;
  final double size;

  @override
  Widget build(BuildContext context) {
    return loc != null
        ? Image.asset(
            'assets/language-flags/${getLocaleFullName(loc).toLowerCase()}.png',
            width: size,
          )
        : Container();
  }
}
