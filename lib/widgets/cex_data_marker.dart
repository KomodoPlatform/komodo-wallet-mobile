import 'package:flutter/material.dart';
import '../blocs/dialog_bloc.dart';
import '../localizations.dart';
import '../widgets/custom_simple_dialog.dart';
import '../widgets/html_parser.dart';
import '../app_config/theme_data.dart';

class CexMarker extends StatelessWidget {
  const CexMarker(
    this.context, {
    this.size = const Size(16, 16),
    this.color = cexColor,
  });

  final Size size;
  final Color color;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => showCexDialog(context),
      child: Icon(
        Icons.info_outline,
        size: size.height,
        color: Theme.of(context).brightness == Brightness.light
            ? cexColorLight
            : cexColor.withOpacity(0.8),
      ),
    );
  }
}

void showCexDialog(BuildContext context) {
  dialogBloc.dialog = showDialog<void>(
    context: context,
    builder: (BuildContext context) => CustomSimpleDialog(
      title: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 22,
            color: Theme.of(context).brightness == Brightness.light
                ? cexColorLight
                : cexColor.withOpacity(0.8),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(AppLocalizations.of(context).cexData),
        ],
      ),
      children: <Widget>[
        HtmlParser(
          AppLocalizations.of(context).cexDataDesc,
          linkStyle: TextStyle(color: Colors.blue),
          textStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? cexColorLight
                : cexColor.withOpacity(0.8),
          ),
        ),
      ],
    ),
  ).then((dynamic _) => dialogBloc.dialog = null);
}
