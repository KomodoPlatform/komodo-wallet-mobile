import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:uuid/uuid.dart';

WalletBloc walletBloc = WalletBloc();

class WalletBloc implements BlocBase {
  List<Wallet> wallets = <Wallet>[];

  // Streams to handle the list coin
  final StreamController<List<Wallet>> _walletsController =
      StreamController<List<Wallet>>.broadcast();
  Sink<List<Wallet>> get _inWallets => _walletsController.sink;
  Stream<List<Wallet>> get outWallets => _walletsController.stream;

  Wallet currentWallet;

  // Streams to handle the list coin
  final StreamController<Wallet> _currentWalletController =
      StreamController<Wallet>.broadcast();
  Sink<Wallet> get _inCurrentWallet => _currentWalletController.sink;
  Stream<Wallet> get outCurrentWallet => _currentWalletController.stream;

  @override
  void dispose() {
    _walletsController.close();
    _currentWalletController.close();
  }

  Future<List<Wallet>> getWalletsSaved() async {
    final List<Wallet> wallets = await Db.getAllWallet();
    this.wallets = wallets;
    _inWallets.add(this.wallets);
    return this.wallets;
  }

  Future<String> loginWithPassword(BuildContext context, String password, Wallet wallet) async{
    final EncryptionTool entryptionTool = EncryptionTool();
    final String seedPhrase = await entryptionTool.readData(KeyEncryption.SEED, wallet, password);

    if (seedPhrase != null) {
        await Db.saveCurrentWallet(wallet);
      return seedPhrase;
    } else {
      throw AppLocalizations.of(context).wrongPassword;
    }
  }

  void initCurrentWallet(String name) {
    currentWallet = Wallet(id: Uuid().v1(), name: name);
    _inCurrentWallet.add(currentWallet);
  }

  void setCurrentWallet(Wallet wallet) {
    currentWallet = wallet;
    _inCurrentWallet.add(currentWallet);
  }

  Future<void> deleteCurrentWallet() async {
    await Db.deleteWallet(currentWallet);
                                          authBloc.logout();

  }

  Future<void> deleteSeedPhrase(String password, Wallet wallet) async {
    final EncryptionTool entryptionTool = EncryptionTool();
    await entryptionTool.deleteData(KeyEncryption.SEED, wallet, password);
    await entryptionTool.deleteData(KeyEncryption.PIN, wallet, password);
  }
}
