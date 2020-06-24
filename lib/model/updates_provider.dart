import 'package:flutter/material.dart';

class UpdatesProvider extends ChangeNotifier {
  bool isFetching = false;
  bool newVersionAvailable = false;
  bool updateRequired = false;
}