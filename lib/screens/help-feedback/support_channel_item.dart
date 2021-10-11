import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/utils.dart';

class SupportChannelItem extends StatelessWidget {
  const SupportChannelItem(this.data);

  final SupportChannel data;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: data.link == null
          ? null
          : () {
              launchURL(data.link);
            },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (data.icon != null) data.icon,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (data.subtitle != null) Text(data.subtitle),
                if (data.title != null) Text(data.title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SupportChannel {
  SupportChannel({this.title, this.subtitle, this.link, this.icon});

  String title;
  String subtitle;
  String link;
  Widget icon;
}
