import 'package:flutter/material.dart';

enum LogoType { full, icon }

class AppLogo extends StatelessWidget {
  const AppLogo.full({
    Key? key,
    bool color = true,
  })  : _type = LogoType.full,
        _hasColor = color,
        super(key: key);

  const AppLogo.icon({Key? key})
      : _type = LogoType.icon,
        _hasColor = true,
        super(key: key);

  final LogoType _type;
  final bool _hasColor;

  @override
  Widget build(BuildContext context) {
    final assetBrightness = Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    Widget image = Image.asset(
      _type == LogoType.full
          ? _fullAssetPath(
              assetBrightness: assetBrightness,
              hasColor: _hasColor,
            )
          : _iconAssetPath(
              assetBrightness: assetBrightness,
            ),
      fit: BoxFit.contain,
    );

    if (_type == LogoType.full &&
        !_hasColor &&
        assetBrightness == Brightness.light) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        child: image,
      );
    }

    return LimitedBox(
      maxHeight: _type == LogoType.full ? 40 : 24,
      child: image,
    );
  }

  String _fullAssetPath({
    required Brightness assetBrightness,
    required bool hasColor,
  }) {
    if (hasColor) {
      return assetBrightness == Brightness.dark
          ? 'assets/branding/mark_and_text_vertical_dark.png'
          : 'assets/branding/mark_and_text_vertical_light.png';
    } else {
      debugPrint('Using dark mode logo for light mode because no light mode'
          'logo exists yet.');
      return assetBrightness == Brightness.dark
          ? 'assets/branding/mark_and_text_vertical_white.png'
          : 'assets/branding/mark_and_text_vertical_white.png';
    }
  }

  String _iconAssetPath({required Brightness assetBrightness}) {
    if (assetBrightness == Brightness.dark) {
      return 'assets/branding/logo_app_light.png';
    } else {
      return 'assets/branding/logo_app.png';
    }
  }
}


// Available assets:
//  Full:
//    - assets/branding/mark_and_text_vertical_light.png (Dark mode)
//    - assets/branding/mark_and_text_vertical_dark.png (Light mode)
//    - assets/branding/mark_and_text_vertical_white.png (Dark mode, color = false)
//    - TODO: Add light mode version of no-color logo. Would be identical
//      except instead of white, it would be black. 
// Icon:
//    - assets/branding/logo_app_light.png
//    - assets/branding/logo_app.png