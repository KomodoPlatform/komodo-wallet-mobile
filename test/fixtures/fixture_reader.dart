import 'dart:io';

Directory testDir() {
  // `flutter test` sets the current directory to the "test" folder.
  // Running tests from IDE might use the root of the project instead.

  final inTest = Directory.current.path.endsWith('test');
  if (inTest) {
    return Directory.current;
  } else {
    final test = Directory(Directory.current.path + '/test');
    assert(test.existsSync());
    return test;
  }
}

String fixture(String name) {
  final test = testDir();
  final path = '${test.path}/fixtures/$name';
  return File(path).readAsStringSync();
}
