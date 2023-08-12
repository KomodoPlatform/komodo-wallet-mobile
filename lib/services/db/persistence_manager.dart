import 'package:hive/hive.dart';
import 'package:komodo_dex/packages/account_addresses/api/account_addresses_api_hive.dart';
import 'package:komodo_dex/packages/account_addresses/repository/account_addresses_repository.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/utils.dart';

class PersistenceManager {
  PersistenceManager._();

  static Future<void> init() async {
    Hive.init((await applicationDocumentsDirectory).path + '/hive');

    final accountAddressesRepository = AccountAddressesRepository(
      accountAddressesApi: await AccountAddressesApiHive.initialize(),
    );

    await Db.init(accountAddressesRepository: accountAddressesRepository);
  }
}
