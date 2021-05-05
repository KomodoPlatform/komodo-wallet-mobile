import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/utils/log.dart';

class Backup {
  Backup({
    this.notes,
    this.contacts,
    this.swaps,
  });

  factory Backup.fromJson(Map<String, dynamic> json) {
    final Map<String, Contact> contacts = {};
    final Map<String, MmSwap> swaps = {};
    json['contacts']?.forEach((String uid, dynamic contactJson) {
      contacts[uid] = Contact.fromJson(contactJson);
    });
    json['swaps']?.forEach((String uuid, dynamic swapJson) {
      try {
        swaps[uuid] = MmSwap.fromJson(swapJson);
      } catch (e) {
        Log('backup.dart:22]', e.toString());
      }
    });

    return Backup(
      notes: Map.from(json['notes'] ?? <String, String>{}),
      contacts: contacts,
      swaps: swaps,
    );
  }

  Map<String, String> notes;
  Map<String, Contact> contacts;
  Map<String, MmSwap> swaps;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'notes': notes,
      'contacts': contacts,
      'swaps': swaps,
    };
  }
}
