// ignore_for_file: strict_raw_type

import 'dart:async';
import 'package:flutter/material.dart';

/// A mixin for [StatefulWidget]s that rebuilds the widget when any of the
/// watched streams emit a value.
///
/// This is useful for legacy pages that use multiple streambuilders to trigger
/// the UI rebuild. Common with generic legacy blocs.
///
/// Override [onData] if you need to do something when a stream emits a value.
///
/// Type [S] is the type of the stream data. This can be dynamic if you don't
/// plan on  overriding [onData] or if the streams are of different types.
mixin MultiStreamRebuilderMixin<T extends StatefulWidget, S extends dynamic>
    on State<T> {
  final List<StreamSubscription> _subscriptions = [];

  /// The widget will rebuild when any of the streams emit a value.
  ///
  /// NB: Ensure that the stream is a broadcast stream if there could be
  /// multiple listeners.
  List<Stream<S>> get watchedStreams;

  // Commented out because this seems like a bad idea to be tapping into the
  // onData callbacks of the subscriptions and modifying them. Investigate
  // if there is another approach to trigger the widget rebuild from existing
  // stream subscriptions.
  // /// The widget will rebuild when any of the subscriptions emit a value.
  // List<StreamSubscription> get watchedSubscriptions => [];

  // Optional callback to run before the widget is rebuilt because of a stream
  // emitting a value.
  void onData(S data) {
    //
  }

  @mustCallSuper
  @override
  void initState() {
    super.initState();

    // _onDataCallbacks = _subscriptions.map((e) => e.onData).toList();

    // See commented out [watchedSubscriptions] getter.
    // for (final subscription in watchedSubscriptions) {
    //   final onData = subscription.onData;

    //   subscription.onData((data) {
    //     onData.call(data);
    //     setState(() {});
    //   });
    // }

    for (final stream in watchedStreams) {
      _subscriptions.add(
        stream.listen((data) {
          onData.call(data);
          setState(() {});
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }
}
