import 'package:flutter/material.dart';

class ExportImportListItem {
  ExportImportListItem({
    this.child,
    this.checked,
    this.onChange,
  });

  Widget child;
  bool checked;
  Function(bool) onChange;
}
