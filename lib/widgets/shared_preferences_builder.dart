import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesBuilder<T> extends StatelessWidget {
  const SharedPreferencesBuilder(
      {Key key, @required this.pref, @required this.builder, this.initialData})
      : super(key: key);

  final String pref;
  final AsyncWidgetBuilder<T> builder;
  final T initialData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: _future(),
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          return this.builder(context, snapshot);
        });
  }

  Future<T> _future() async {
    return (await SharedPreferences.getInstance()).get(pref);
  }
}
