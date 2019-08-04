// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart';

import 'messages_de.dart' as messages_de;
import 'messages_fr.dart' as messages_fr;
import 'messages_messages.dart' as messages_messages;
import 'messages_zh.dart' as messages_zh;
import 'messages_zh_hant.dart' as messages_zh_hant;

typedef LibraryLoader = void Function();

Map<String, LibraryLoader> _deferredLibraries = <String, LibraryLoader>{
// ignore: unnecessary_new
  'fr': () => new Future<dynamic>.value(null),
// ignore: unnecessary_new
  'de': () => new Future<dynamic>.value(null),
// ignore: unnecessary_new
  'messages': () => new Future<dynamic>.value(null),
  // ignore: unnecessary_new
  'zh': () => new Future<dynamic>.value(null),
// ignore: unnecessary_new
  'zh_hant': () => new Future<dynamic>.value(null),
};

MessageLookupByLibrary _findExact(dynamic localeName) {
  switch (localeName) {
    case 'fr':
      return messages_fr.messages;
    case 'de':
      return messages_de.messages;
    case 'messages':
      return messages_messages.messages;
    case 'zh':
      return messages_zh.messages;
    case 'zh_hant':
      return messages_zh_hant.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  final String availableLocale = Intl.verifiedLocale(
      localeName, (dynamic locale) => _deferredLibraries[locale] != null,
      onFailure: (dynamic _) => null);
  if (availableLocale == null) {
    // ignore: unnecessary_new
    return new Future<bool>.value(false);
  }
  final Function lib = _deferredLibraries[availableLocale];
  // ignore: unnecessary_new
  await (lib == null ? new Future<bool>.value(false) : lib());
  // ignore: unnecessary_new
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  // ignore: unnecessary_new
  return new Future<bool>.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary _findGeneratedMessagesFor(dynamic locale) {
  final String actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (dynamic _) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
