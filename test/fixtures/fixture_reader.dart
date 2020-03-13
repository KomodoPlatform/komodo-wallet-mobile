import 'dart:io';

String fixture(String name) {
  print(Directory.current);
  return File('fixtures/$name').readAsStringSync();
}
