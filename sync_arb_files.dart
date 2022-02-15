import 'dart:convert';
import 'dart:io';

void main() {
  const String messagesPath = 'lib/l10n/intl_messages.arb';

  print('\nLoading $messagesPath...');
  final Map<String, dynamic> messagesJson = getJsonFromFile(messagesPath);
  print('Done. ${messagesJson.length} keys found.');

  final Map<String, String> localePaths =
      getLocalePaths(Directory('lib/l10n/'));

  localePaths.forEach((locale, path) {
    print('\nProcessing locale: \'$locale\'...');

    final Map<String, dynamic> currentLocaleJson = getJsonFromFile(path);
    final Map<String, dynamic> newLocaleJson = {};

    int updatesCounter = 0;

    messagesJson.forEach((key, message) {
      if (key.startsWith('@')) return;

      final String currentLocaleMessage = currentLocaleJson[key];
      final String newLocaleMessage =
          isLocaleMessageValid(message, currentLocaleMessage)
              ? currentLocaleMessage
              : '';

      if (currentLocaleMessage != newLocaleMessage) updatesCounter++;

      newLocaleJson[key] = newLocaleMessage;
      newLocaleJson['@$key'] = messagesJson['@$key'];
    });

    writeJsonToFile(newLocaleJson, path);

    print('Done. $updatesCounter keys updated.');
  });
}

bool isLocaleMessageValid(String message, String localeMessage) {
  if (localeMessage == null) return false;

  return placeholdersEqual(message, localeMessage);
}

bool placeholdersEqual(String message, String localeMessage) {
  final RegExp regExp = RegExp(r'{(.*?)}');
  final List<Match> messageMatches = regExp.allMatches(message).toList();
  final List<Match> localeMessageMatches =
      regExp.allMatches(localeMessage).toList();

  final bool isEqual = extractPlaceholders(messageMatches).join('') ==
      extractPlaceholders(localeMessageMatches).join('');

  return isEqual;
}

List<String> extractPlaceholders(List<Match> matches) {
  List<String> placeholders = [];

  for (Match match in matches) {
    final String placeholder = match.group(0);
    if (!placeholders.contains(placeholder)) placeholders.add(placeholder);
  }

  placeholders.sort((a, b) => a.compareTo(b));
  return placeholders;
}

void writeJsonToFile(Map<String, dynamic> json, String filePath) {
  final String spaces = ' ' * 4;
  final JsonEncoder encoder = JsonEncoder.withIndent(spaces);

  File(filePath).writeAsStringSync(encoder.convert(json));
}

Map<String, dynamic> getJsonFromFile(String filePath) {
  Map<String, dynamic> json;

  try {
    final String messagesString = File(filePath).readAsStringSync();
    json = jsonDecode(messagesString);
  } catch (e) {
    print('Unable to load json from $filePath:\n$e');
    rethrow;
  }

  return json;
}

Map<String, String> getLocalePaths(Directory dir) {
  print('\nGetting locale files list...');

  final Map<String, String> paths = {};
  final List<FileSystemEntity> entities = dir.listSync().toList();

  for (FileSystemEntity entity in entities) {
    if (entity is! File) continue;

    final Match match = RegExp('.*\/intl_(.*)\.arb').firstMatch(entity.path);
    if (match == null) continue;

    final String locale = match.group(1);
    if (locale == 'messages') continue;

    paths[locale] = entity.path;
  }

  if (paths.isEmpty) {
    print('Nothing found.');
  } else {
    print('Done. ${paths.length} locales found: ${paths.keys.join(', ')}.');
  }

  return paths;
}
