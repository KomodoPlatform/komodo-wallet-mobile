import 'dart:io';

String fixture(String name) {
  // `flutter test` sets the current directory to the "test" folder.
  // Running tests from IDE might use the root of the project instead.

  final inTest = Directory.current.path.endsWith('test');
  final path = inTest ? 'fixtures/$name' : 'test/fixtures/$name';
  return File(path).readAsStringSync();
}
