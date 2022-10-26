import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';

void testEncryptDecrypt() {
  String data1 = 'Data1';
  final encrypted1 = EncryptionTool().encryptData('password', data1);

  final decrypted1 = EncryptionTool().decryptData('password', encrypted1);

  expect(decrypted1, data1, reason: 'The decrypted1 does not equals the data1');

  String data2 = [1, 2, 3, 4, 5, 6].toString();
  final encrypted2 = EncryptionTool().encryptData('1234', data2);
  final decrypted2 = EncryptionTool().decryptData('1234', encrypted2);

  expect(decrypted2, data2, reason: 'The decrypted2 does not equals the data2');

  String data3 = {'name': 'Firo', 'age': 23}.toString();
  final encrypted3 = EncryptionTool().encryptData('Pas@1234', data3);
  final decrypted3 = EncryptionTool().decryptData('Pas@1234', encrypted3);

  expect(decrypted3, data3, reason: 'The decrypted3 does not equals the data3');

  // test: decrypt backward compatibility
  String legacyEncryptedData =
      'S53A6VypGuD0QImZ/bPkUR1RowsV30OHsRVgJzBYG9/uVE3MeLA04rtI2vEVPGrcyGhcYrLcnk0ArrYhxD9gRAmPMuXclU1QQPGd/QvWED4FPjHsussvQraYcEqeOEgz9Pt9ASM0dEpn8jaHAjyObsj4QKkN8mW6QMrEkadeRVNJ+5h/Gc2pSTS+QVLaF4IFa/1NqVXiDmQ12bjpxhR4ZAAxki1HB9ZqKGjfAxlYFxU=';
  String newlyEncryptedData =
      'maTt1GbUQv6vGIDM8zoJug==2tBbg6fPleY418g/Dy9MbMgvc2fpq/K8eIqcD1vUuCw4hSptWAZG5+0NsFgUXYo0Z6B/TYC7fD3QvKkB2dSStZ2gpBhs0jzMmTDhuRRBcSoy03TdwClftqRXj7/UQo9PsSHtc1UAqA96vE/amfmfEcxv2xPGiSCzvJYxnF7Gu2ArA7+JYf2dnx9Aq1IFcDQCyNl0EmSmhq+n5f19PwuGuQRsGDsnpYSTfCQ4ltl/cIjhNDuAuB+Ykwg5NA==';

  String data =
      '{"notes":{},"contacts":{"f8691810-5513-11ed-b08b-276982f23b06":{"name":"wewr","uid":"f8691810-5513-11ed-b08b-276982f23b06","addresses":{"MATIC":"wrearfaerr"}}},"swaps":{}}';

  final legacyDecrypted =
      EncryptionTool().decryptData('pass', legacyEncryptedData);
  final newlyDecrypted =
      EncryptionTool().decryptData('pass', newlyEncryptedData);

  // legacy decrypted data should be equal to newly decrypted data
  expect(legacyDecrypted, newlyDecrypted,
      reason: 'The legacyDecrypted does not equals the newlyDecrypted');
  // legacy decrypted data should be equal to hardcoded decrypted data
  expect(legacyDecrypted, data,
      reason: 'The legacyDecrypted does not equals the data');
}
