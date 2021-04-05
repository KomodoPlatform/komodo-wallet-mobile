import 'package:flutter/material.dart';

DialogBloc dialogBloc = DialogBloc();

class DialogBloc {
  Future<void> dialog;

  void closeDialog(BuildContext context) {
    if (dialog != null) {
      dialog = null;
      Navigator.of(context).pop();
    }
  }
}
