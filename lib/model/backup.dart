import 'package:komodo_dex/model/addressbook_provider.dart';

class Backup {
  Backup({
    this.notes,
    this.contacts,
  });

  factory Backup.fromJson(Map<String, dynamic> json) {
    final Map<String, Contact> contacts = {};
    json['contacts']?.forEach((String uid, dynamic contactJson) {
      contacts[uid] = Contact.fromJson(contactJson);
    });

    return Backup(
      notes: Map.from(json['notes'] ?? <String, String>{}),
      contacts: contacts,
    );
  }

  Map<String, String> notes;
  Map<String, Contact> contacts;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'notes': notes,
      'contacts': contacts,
    };
  }
}
