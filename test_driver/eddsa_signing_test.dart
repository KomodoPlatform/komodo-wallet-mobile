// [build] rsync --delete -az --out-format=%n%L --chmod=D770,F660 '--filter=. /c/spool/synced/projects/club/mac-ui-build.rules' /c/spool/komodoDEX/ administrator@macinvault:Desktop/komodoDEX/
// [build] ssh administrator@macinvault '. .profile; cd Desktop/komodoDEX && flutter drive --target=test_driver/eddsa_signing.dart'

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<void> main() async {
  FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  group('EdDSA', () {
    test('foobar', () async {
      expect(await driver.requestData('sign "foobar"'), 'okay');
    });
  });

  group('Public key encryption', () {
    test('foobar', () async {
      expect(await driver.requestData('encrypt "foobar"'), 'okay');
    });
  });
}
