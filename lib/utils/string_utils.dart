import 'dart:math';

/// An extension on the String class that provides a method to get initials
/// from a string.
///
/// Usage:
///   String name = "John Doe";
///   print(name.initials(2)); // Output: "JD"
///   String singleName = "Alice";
///   print(singleName.initials(3)); // Output: "ALI"
extension StringInitials on String {
  /// Returns the initials of the string, based on the given [targetLength].
  ///
  /// This method takes the first [targetLength] characters from the string if it
  /// contains only one word, or the first letter of the first [targetLength]
  /// words if it contains multiple words.
  ///
  /// The returned initials are in uppercase.
  ///
  /// Examples:
  /// ```
  /// "John Doe".initials(2); // "JD"
  /// "Alice".initials(3); // "ALI"
  /// "Elon Reeve Musk".initials(3); // "ERM"
  /// ```
  ///
  /// [targetLength] must be a positive integer.
  String initials(int targetLength) {
    assert(targetLength > 0, 'targetLength must be a positive integer.');
    String result = '';
    List<String> words = split(' ');

    if (words.length > 1) {
      final takeWords = min(targetLength, words.length);
      result = words.sublist(0, takeWords).map((word) => word[0]).join();
    } else {
      result = substring(0, min(targetLength, length));
    }

    return result.toUpperCase();
  }
}

extension StringCaseExtension on String {
  /// Converts a string to start case.
  ///
  /// E.g. "heLLO world" becomes "Hello World".
  String toStartCase() {
    return split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Converts a string to sentence case.
  ///
  /// E.g. "hello woRLd" becomes "Hello world".
  String toSentenceCase() {
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
