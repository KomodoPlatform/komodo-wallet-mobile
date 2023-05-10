import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/app/widgets/main_app.dart';
import 'package:komodo_dex/services/bloc/app_providers.dart';
import 'package:komodo_dex/services/bloc/bloc_manager_widget.dart';

import '../utils/log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // mmSe.metrics();
    // await startup.start();
    await BlocManager.init();
    return runApp(
      BlocManagerWidget(
        child: AppProviderManager(
          child: MainApp(),
        ),
      ),
    );
  } catch (e) {
    Log('main:46', 'startApp] $e');
    rethrow;
  }
}
