// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references
// ignore_for_file:avoid_catches_without_on_clauses

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_de.dart' deferred as messages_de;
import 'messages_es.dart' deferred as messages_es;
import 'messages_fr.dart' deferred as messages_fr;
import 'messages_hu.dart' deferred as messages_hu;
import 'messages_ja.dart' deferred as messages_ja;
import 'messages_ko.dart' deferred as messages_ko;
import 'messages_messages.dart' deferred as messages_messages;
import 'messages_ru.dart' deferred as messages_ru;
import 'messages_tr.dart' deferred as messages_tr;
import 'messages_zh.dart' deferred as messages_zh;
import 'messages_zh_Hans.dart' deferred as messages_zh_hans;
import 'messages_zh_TW.dart' deferred as messages_zh_tw;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'de': messages_de.loadLibrary,
  'es': messages_es.loadLibrary,
  'fr': messages_fr.loadLibrary,
  'hu': messages_hu.loadLibrary,
  'ja': messages_ja.loadLibrary,
  'ko': messages_ko.loadLibrary,
  'messages': messages_messages.loadLibrary,
  'ru': messages_ru.loadLibrary,
  'tr': messages_tr.loadLibrary,
  'zh': messages_zh.loadLibrary,
  'zh_Hans': messages_zh_hans.loadLibrary,
  'zh_TW': messages_zh_tw.loadLibrary,
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'de':
      return messages_de.messages;
    case 'es':
      return messages_es.messages;
    case 'fr':
      return messages_fr.messages;
    case 'hu':
      return messages_hu.messages;
    case 'ja':
      return messages_ja.messages;
    case 'ko':
      return messages_ko.messages;
    case 'messages':
      return messages_messages.messages;
    case 'ru':
      return messages_ru.messages;
    case 'tr':
      return messages_tr.messages;
    case 'zh':
      return messages_zh.messages;
    case 'zh_Hans':
      return messages_zh_hans.messages;
    case 'zh_TW':
      return messages_zh_tw.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  final availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null);
  if (availableLocale == null) {
    return Future.value(false);
  }
  final lib = _deferredLibraries[availableLocale];
  await (lib == null ? Future.value(false) : lib());
  initializeInternalMessageLookup(() => CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  final actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
