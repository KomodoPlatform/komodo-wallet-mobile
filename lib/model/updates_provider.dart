import 'package:flutter/material.dart';

class UpdatesProvider extends ChangeNotifier {
  bool newVersionAvailable = true;
  bool updateRequired = true;
}