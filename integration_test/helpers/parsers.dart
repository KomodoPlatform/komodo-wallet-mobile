int parseFirstInt(String string) {
  final regexp = RegExp(r'[0-9]+');
  final match = regexp.firstMatch(string);

  try {
    return int.parse(match.group(0));
  } catch (_) {
    return null;
  }
}
