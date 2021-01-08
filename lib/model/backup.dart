class Backup {
  Backup({
    this.notes,
    this.contacts,
  });

  factory Backup.fromJson(Map<String, dynamic> json) {
    return Backup(
      notes: Map.from(json['notes'] ?? <String, String>{}),
      contacts:
          Map<String, dynamic>.from(json['contacts'] ?? <String, dynamic>{}),
    );
  }

  Map<String, String> notes;
  Map<String, dynamic> contacts;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'notes': notes,
      'contacts': contacts,
    };
  }
}
