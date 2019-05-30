import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

final walletBloc = WalletBloc();

class WalletBloc implements BlocBase {
  List<Wallet> wallets = new List<Wallet>();

  // Streams to handle the list coin
  StreamController<List<Wallet>> _walletsController =
      StreamController<List<Wallet>>.broadcast();
  Sink<List<Wallet>> get _inWallets => _walletsController.sink;
  Stream<List<Wallet>> get outWallets => _walletsController.stream;

  @override
  void dispose() {
    _walletsController.close();
  }

  Future<List<Wallet>> getWalletsSaved() async {
    List<Wallet> wallets = await DBProvider.db.getAllWallet();
    this.wallets = wallets;
    _inWallets.add(this.wallets);
    return this.wallets;
  }

  Future<void> loginWithPassword(BuildContext context, String password, Wallet wallet) async{
    var entryptionTool = new EncryptionTool();
    var seedPhrase = await entryptionTool.readData(wallet, password);

    if (seedPhrase != null) {
      await authBloc.loginUI(true, seedPhrase);
    } else {
      throw(AppLocalizations.of(context).wrongPassword);
    }
  }

}
