import 'dart:async';

import 'package:komodo_dex/services/db/legacy_db_adapter.dart';
import 'package:komodo_dex/utils/utils.dart';

import '../generic_blocs/authenticate_bloc.dart';
import '../model/wallet.dart';
import '../services/db/database.dart';
import '../utils/encryption_tool.dart';
import '../widgets/bloc_provider.dart';

WalletBloc walletBloc = WalletBloc();

class WalletBloc implements GenericBlocBase {
  List<Wallet> wallets = <Wallet>[];

  Wallet? currentWallet;

  @override
  void dispose() {
    //
  }

  Future<List<Wallet>> getWalletsSaved() async {
    pauseUntil(() => LegacyDatabaseAdapter.maybeInstance != null);

    final wallets = await LegacyDatabaseAdapter.maybeInstance!.listWallets();
    this.wallets = wallets;
    return this.wallets;
  }

  void setCurrentWallet(Wallet? wallet) {
    currentWallet = wallet;
  }

  Future<void> deleteWallet(Wallet wallet) async {
    throw UnimplementedError(
      'TODO: Implement wallet deletion in refactored'
      'bloc(s)code',
    );
    await Db.deleteWallet(wallet);
    authBloc.logout();
  }

  Future<void> deleteSeedPhrase(String? password, Wallet wallet) async {
    final EncryptionTool entryptionTool = EncryptionTool();
    await entryptionTool.deleteData(KeyEncryption.SEED, wallet, password);
    await entryptionTool.deleteData(KeyEncryption.PIN, wallet, password);
    await entryptionTool.deleteData(KeyEncryption.CAMOPIN, wallet, password);
  }
}
