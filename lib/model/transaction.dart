import 'package:intl/intl.dart';

class Transaction {
  final String txid;
  final bool isIn;
  final double value;
  final bool isConfirm;
  final DateTime date;

  Transaction({this.txid, this.isIn, this.value, this.isConfirm, this.date});

  String getTimeFormat() {
    return DateFormat('dd MMM yyyy HH:mm').format(date);
  }

  int compareTo(Transaction other) {
    int order = other.date.compareTo(date);
    if (order == 0) order = date.compareTo(other.date);
    return order;
  }
}
