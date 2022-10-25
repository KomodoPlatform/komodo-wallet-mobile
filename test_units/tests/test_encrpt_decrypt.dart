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
}
