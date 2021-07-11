import 'package:flutter/material.dart';

class EmptyListMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.only(right: 12),
      child: Center(
        child: Text(
          'Nothing found',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }
}
