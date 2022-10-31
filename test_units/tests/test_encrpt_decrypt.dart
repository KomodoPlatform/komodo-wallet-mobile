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
      'S53A6VypGuD0QImZ/bPkUR1RowsV30OHsRc7dWwPFIjuVE3Ae7Q04rtI2vFOOTHYyGJYY7+BnBoL/7J3xj9gRAmPMuXclU1QUuaP+F2NVzwILmGz7No1WK3cIR+ML19ipqw1ViU3IEow+zzSAj+IPZXtS/pcpyqyRd/c1vYLGENK7t84Rs3yVnKBZXXgMdMdc/EdiWDYSj9y3725zB1jP1YkkTtFEYA1J3CAe2EgPjJXq8ODE2kTskkl4a8Rx/64';
  String newlyEncryptedData =
      'FxyTXZc2L2s/x9dh8WG21A==lfKQCRecyIAh5O3hpQ0vmA==fpCyL23VQehBOjadVbIDKYI61JjYxdaOQ56JCGTz8LHz6rgjC0gzd/7YpEH4QfZ4geAiDH6egCZuGyoiDYySY+fMtNx+gewi9tYA2ybAOXlJTXpBl8thqiNbSe4CRNBXni+zaoI7Qn1CI2FTL49JeUDoyT4+mJzMJcEYBTwGbSvRv5ev4yvbe8P3AClx3oxlh8obLHg9pJUQexUlPgF7eRB34NlKIPyNJqFtAjC5MV430ofUvh8UDFk/2SA8xym1o6V0JEabWHdQIw==';
  String data =
      '{"notes":{},"contacts":{"dcdef7f0-5927-11ed-95cf-8374e019bff4":{"name":"erewtwewdtretw","uid":"dcdef7f0-5927-11ed-95cf-8374e019bff4","addresses":{"ETH":"twrwtfwtftwretete"}}},"swaps":{}}';

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
