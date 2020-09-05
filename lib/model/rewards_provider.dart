import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';

class RewardsProvider extends ChangeNotifier {
  List<RewardsItem> _rewards;

  List<RewardsItem> get rewards {
    if (_rewards == null || _rewards.isEmpty) _updateInfo();
    return _rewards;
  }

  double get total {
    double t = 0;
    for (RewardsItem item in _rewards) {
      t += item.reward ?? 0.0;
    }
    return t;
  }

  void update() => _updateInfo();

  Future<void> _updateInfo() async {
    List<RewardsItem> list;
    try {
      list = await MM.getRewardsInfo();
    } catch (e) {
      print(e);
      return;
    }

    _rewards = list;
    notifyListeners();
  }

  Future<void> receive() async {
    final CoinBalance kmd = coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == 'KMD',
        orElse: () => null);

    if (kmd == null) return;

    final dynamic res = await ApiProvider().postWithdraw(
        MMService().client,
        GetWithdraw(
          userpass: MMService().userpass,
          coin: 'KMD',
          to: kmd.balance.address,
          max: true,
        ));

    if (res is WithdrawResponse) {
      final dynamic tx = await ApiProvider().postRawTransaction(
          MMService().client,
          GetSendRawTransaction(coin: 'KMD', txHex: res.txHex));

      if (tx is SendRawTransactionResponse && tx.txHash.isNotEmpty) {
        await Future<dynamic>.delayed(const Duration(seconds: 3));
        update();
      }
    }
  }
}

class RewardsItem {
  RewardsItem({
    this.index,
    this.amount,
    this.reward,
    this.startAt,
    this.stopAt,
    this.error,
  });

  factory RewardsItem.fromJson(Map<String, dynamic> json) {
    final double reward = json['accrued_rewards']['Accrued'] != null
        ? double.parse(json['accrued_rewards']['Accrued'])
        : null;

    final String error = json['accrued_rewards']['NotAccruedReason'];
    String errorMessage;
    String errorMessageLong;
    switch (error) {
      case 'UtxoAmountLessThanTen':
        errorMessage = '<10 KMD';
        errorMessageLong = 'UTXO amount less than 10 KMD';
        break;
      case 'TransactionInMempool':
        errorMessage = '...';
        errorMessageLong = 'Transaction is in progress';
        break;
      case 'OneHourNotPassedYet':
        errorMessage = '<1 hour';
        errorMessageLong = 'One hour not passed yet';
        break;
      default:
        errorMessage = '?';
        errorMessageLong = error;
    }

    return RewardsItem(
      index: json['output_index'],
      amount: double.parse(json['amount']),
      reward: reward,
      startAt: json['accrue_start_at'],
      stopAt: json['accrue_stop_at'],
      error: {'short': errorMessage, 'long': errorMessageLong},
    );
  }

  int index;
  double amount;
  double reward;
  int startAt;
  int stopAt;
  Map<String, String> error;
}
