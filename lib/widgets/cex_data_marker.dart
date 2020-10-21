import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/html_parser.dart';
import 'package:komodo_dex/widgets/theme_data.dart';

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
    return Container(
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: () => showCexDialog(context),
        child: Icon(
          Icons.info_outline,
          size: size.height,
          color: color,
        ),
      ),
    );
  }
}

void showCexDialog(BuildContext context) {
  dialogBloc.dialog = showDialog(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 22,
            color: cexColor,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(AppLocalizations.of(context).cexData),
        ],
      ),
      contentPadding: const EdgeInsets.all(20),
      children: <Widget>[
        HtmlParser(
          AppLocalizations.of(context).cexDataDesc,
          linkStyle: TextStyle(color: Colors.blue),
        ),
      ],
    ),
  );
}
