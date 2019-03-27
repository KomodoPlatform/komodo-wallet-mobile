// To parse this JSON data, do
//
//     final uuid = uuidFromJson(jsonString);

import 'dart:convert';

Uuid uuidFromJson(String str) {
    final jsonData = json.decode(str);
    return Uuid.fromJson(jsonData);
}

String uuidToJson(Uuid data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Uuid {
    String uuid;
    String pubkey;

    Uuid({
        this.uuid,
        this.pubkey,
    });

    factory Uuid.fromJson(Map<String, dynamic> json) => new Uuid(
        uuid: json["uuid"],
        pubkey: json["pubkey"],
    );

    Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "pubkey": pubkey,
    };
}