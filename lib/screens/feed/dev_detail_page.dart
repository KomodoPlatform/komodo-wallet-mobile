import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/devops_tab.dart';

class DevDetailsPage extends StatelessWidget {
  const DevDetailsPage({
    this.dev,
  });

  final Dev dev;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 15,
              backgroundImage:
                  dev.image != null ? NetworkImage(dev.image) : null,
              backgroundColor: Theme.of(context).disabledColor,
              child: dev.image == null
                  ? Icon(
                      Icons.account_circle,
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(dev.name),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[],
            ),
          ),
        ),
      ),
    );
  }
}
