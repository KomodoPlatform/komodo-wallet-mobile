import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

class RewardsProvider extends ChangeNotifier {
  RewardsProvider() {
    update();
  }

  List<RewardsItem> _rewards;

  bool claimInProgress = false;
  bool updateInProgress = false;
  String errorMessage;
  String successMessage;

  List<RewardsItem> get rewards {
    return _rewards;
  }

  double get total {
    double t = 0;
    for (RewardsItem item in _rewards) {
      t += item.reward ?? 0.0;
    }
    return t;
  }

  bool get needClaim {
    if (_rewards == null) return false;

    for (RewardsItem item in _rewards) {
      if (item.stopAt == null) continue;

      final Duration timeLeft = Duration(
        milliseconds:
            item.stopAt * 1000 - DateTime.now().millisecondsSinceEpoch,
      );
      if (timeLeft.inDays < 2 && (item.reward ?? 0) > 0) {
        return true;
      }
    }

    return false;
  }

  Future<void> update() => _updateInfo();

  Future<void> _updateInfo() async {
    if (updateInProgress) return;
    updateInProgress = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    List<RewardsItem> list;
    try {
      list = await MM.getRewardsInfo();
    } catch (e) {
      updateInProgress = false;
      print(e);
      notifyListeners();
      return;
    }

    _rewards = list;
    updateInProgress = false;
    notifyListeners();
  }

  Future<void> receive() async {
    if (claimInProgress) return;
    claimInProgress = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final CoinBalance kmd = coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == 'KMD',
        orElse: () => null);

    if (kmd == null) return;

    dynamic res;
    try {
      res = await ApiProvider().postWithdraw(
          MMService().client,
          GetWithdraw(
            userpass: MMService().userpass,
            coin: 'KMD',
            to: kmd.balance.address,
            max: true,
          ));
    } catch (e) {
      Log('rewards_provider', 'receive/postWithdraw] $e');
      _setError(e);
    }

    if (!(res is WithdrawResponse)) {
      _setError();
      claimInProgress = false;
      return;
    }

    dynamic tx;
    try {
      tx = await ApiProvider().postRawTransaction(MMService().client,
          GetSendRawTransaction(coin: 'KMD', txHex: res.txHex));
    } catch (e) {
      Log('rewards_provider', 'receive/postRawTransaction] $e');
      _setError(e);
    }

    if (!(tx is SendRawTransactionResponse) || tx.txHash.isEmpty) {
      _setError();
      claimInProgress = false;
      return;
    }

    await Future<dynamic>.delayed(const Duration(seconds: 2));
    await _updateInfo();
    successMessage =
        'Success! ${formatPrice(res.myBalanceChange)} KMD received.';

    claimInProgress = false;
    notifyListeners();
  }

  void _setError([String e]) {
    // TODO(yurii): verbose error message
    errorMessage = 'Something went wrong. Please try again later.';
    notifyListeners();
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
        errorMessage = 'processing';
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
