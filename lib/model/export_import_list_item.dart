import 'package:flutter/material.dart';

class ExportImportListItem {
  ExportImportListItem({
    this.child,
    this.checked,
    this.onChange,
    this.zebra = false,
  });

  Widget child;
  bool checked;
  Function(bool) onChange;
  bool zebra;
}
