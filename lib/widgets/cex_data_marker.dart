import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/theme_data.dart';

class CexMarker extends StatelessWidget {
  const CexMarker(this.context, {this.size = const Size(16, 16)});

  final Size size;
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
          color: cexColor,
        ),
      ),
    );
  }
}

void showCexDialog(BuildContext context) {
  const TextStyle style = TextStyle(fontSize: 16);

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
          const Text('CEX data'), // TODO(yurii): localization
        ],
      ),
      contentPadding: const EdgeInsets.all(20),
      children: <Widget>[
        RichText(
            textScaleFactor: 1,
            text: TextSpan(
              children: [
                const TextSpan(
                  text:
                      'Markets data (prices, charts, etc.) marked with the ', // TODO(yurii): localization
                  style: style,
                ),
                WidgetSpan(
                    child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: cexColor,
                )),
                const TextSpan(
                    text:
                        ' icon originates from third party sources (', // TODO(yurii): localization
                    style: style),
                TextSpan(
                    text: 'coingecko.com',
                    style: style,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchURL('https://www.coingecko.com/')),
                WidgetSpan(
                    child: Icon(
                  Icons.open_in_new,
                  size: 16,
                )),
                const TextSpan(
                  text: ')', // TODO(yurii): localization
                  style: style,
                ),
              ],
            )),
      ],
    ),
  );
}
