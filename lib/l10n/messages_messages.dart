// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
MessageLookup messages = new MessageLookup();

// ignore: unused_element
String _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
// typedef MessageIfAbsent(String message_str, List args);

typedef MessageIfAbsent = Future<dynamic> Function(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'messages';

  @override
  Map<String, Function> messages = _notInlinedMessages(_notInlinedMessages);
  static dynamic _notInlinedMessages(dynamic _) => <String, Function> {

  };
}
