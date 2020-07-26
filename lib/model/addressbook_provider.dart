import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddressBookProvider extends ChangeNotifier {
  AddressBookProvider() {
    _init();
  }

  Future<List<Contact>> get contacts async {
    while (_contacts == null) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    }

    return _contacts;
  }

  Contact createContact(String name) {
    final Contact contact = Contact.create(name);
    _contacts.add(contact);
    _saveContacts();
    notifyListeners();

    return contact;
  }

  void deleteContact(Contact contact) {
    _contacts.remove(contact);
    _saveContacts();
    notifyListeners();
  }

  SharedPreferences _prefs;
  List<Contact> _contacts;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadContacts();
  }

  void _loadContacts() {
    List<Contact> saved;
    try {
      saved = jsonDecode(_prefs.getString('addressBook'));
    } catch (_) {}

    if (saved == null) {
      _contacts = [];
    } else {
      _contacts = saved;
    }
    notifyListeners();
  }

  void _saveContacts() {
    _prefs.setString('addressBook', jsonEncode(_contacts));
  }
}

class Contact {
  Contact({
    this.uid,
    this.name,
    this.addresses,
  });

  factory Contact.create(String name) => Contact(
        name: name,
        uid: Uuid().v1(),
        addresses: {
          'KMD': '',
          'BTC': '',
        },
      );

  String uid;
  String name;
  Map<String, String> addresses;
}
