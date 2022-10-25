import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';

Future<void> testEncryptDecrypt() async {
  String data1 = 'Data1';
  final encrypted1 = await EncryptionTool().encryptData('password', data1);
  final decrypted1 = await EncryptionTool().decryptData('password', encrypted1);

  expect(decrypted1, data1, reason: 'The decrypted1 does not equals the data1');

  String data2 = [1, 2, 3, 4, 5, 6].toString();
  final encrypted2 = await EncryptionTool().encryptData('1234', data2);
  final decrypted2 = await EncryptionTool().decryptData('1234', encrypted2);

  expect(decrypted2, data2, reason: 'The decrypted2 does not equals the data2');

  String data3 = {'name': 'Firo', 'age': 23}.toString();
  final encrypted3 = await EncryptionTool().encryptData('Pas@1234', data3);
  final decrypted3 = await EncryptionTool().decryptData('Pas@1234', encrypted3);

  expect(decrypted3, data3, reason: 'The decrypted3 does not equals the data3');

  // test: decrypt backward compatibility
  String legacyEncryptedData =
      'S53A6VypGuD0QImZ/bPkUR1RowsV30OHsUpgKD0NQt3uVE3NK7I04rtI2vEVbmCMyGhYYOjUmxNTpbElkD9gRAmPMuXclU1QUvCY6luIEGdOL3qyupc1TbeQfB/PJk0r8PwyAT9gIQJh72yHHTyUasL0Ef8I+WayE9yKkeoYQEVI+o5pGYrgECyIIkPHHIIFa+9NqUb1D2AizqyumRR4NQ5gljtWBIdyaW7fexhZFhQ=';
  String newlyEncryptedData =
      '{"0":"goJGRAGpeC6AH/vRb83zwSd8S11QOYIti0qNP4kQlxltuw1psTiVmv19VG79sdnbfggm4/hy5CnZ61dQuvZ3GslCqGrbC4T3lljrVT89d8ERxuMXBse1rjYDi2qrtg50JcVwrTybtfCY4vY1dcTWXdFX72M6vgUdhJ0SUm2ccBENnuo8In3cUhVQ/2D0tKxDrcBaSVg6y2rkhWzmnyilzJDKuecG2bJu/FXvqw==","1":"YZvS/1YXwjJziDxb","2":"2qDGXLXkHFrmUwFb","3":"dxj78kAdCSyk8vZhBl4u/A=="}';

  String data =
      '{"notes":{},"contacts":{"9894da30-54b1-11ed-bb22-234c078a8e4b":{"name":"edrerr","uid":"9894da30-54b1-11ed-bb22-234c078a8e4b","addresses":{"ETH":"ereregerefe"}}},"swaps":{}}';

  final legacyDecrypted =
      await EncryptionTool().decryptData('pass', legacyEncryptedData);
  final newlyDecrypted =
      await EncryptionTool().decryptData('pass', newlyEncryptedData);

  // legacy decrypted data should be equal to newly decrypted data
  expect(legacyDecrypted, newlyDecrypted,
      reason: 'The legacyDecrypted does not equals the newlyDecrypted');
  // legacy decrypted data should be equal to hardcoded decrypted data
  expect(legacyDecrypted, data,
      reason: 'The legacyDecrypted does not equals the data');
}
