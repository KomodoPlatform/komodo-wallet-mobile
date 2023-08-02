import 'package:shared_preferences/shared_preferences.dart';

enum SyncType { newTransactions, fullSync, specifiedDate }

String syncTypeToString(SyncType someEnum) {
  return someEnum.toString().split('.').last;
}

SyncType stringToSyncType(String name) {
  return SyncType.values
      .firstWhere((e) => e.toString().split('.').last == name);
}

Future<void> saveZhtlcActivationPrefs(
  Map<String, dynamic> zhtlcActivationPrefs,
) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setString(
    'zhtlcSyncType',
    syncTypeToString(zhtlcActivationPrefs['zhtlcSyncType']),
  );
  prefs.setString(
    'zhtlcSyncStartDate',
    zhtlcActivationPrefs['zhtlcSyncStartDate'].toIso8601String(),
  );
}

Future<Map<String, dynamic>> loadZhtlcActivationPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'zhtlcSyncType': stringToSyncType(prefs.getString('zhtlcSyncType')),
    'zhtlcSyncStartDate': DateTime.parse(prefs.getString('zhtlcSyncStartDate'))
  };
}
