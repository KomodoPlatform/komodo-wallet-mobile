import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit.dart';
import 'package:komodo_dex/screens/addressbook/contacts_list.dart';
import 'package:komodo_dex/widgets/round_button.dart';
import 'package:provider/provider.dart';

class AddressBookPage extends StatefulWidget {
  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBookPage> {
  AddressBookProvider provider;
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AddressBookProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Address Book', // TODO(yurii): localization
          key: Key('addressbook-title'),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RoundButton(
                  onPressed: () {
                    Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const ContactEdit(
                            contact: null,
                          ),
                        ));
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: provider.contacts,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Contact>> snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<Contact> contacts = List.from(snapshot.data);
                contacts.sort((Contact a, Contact b) {
                  return a.name.compareTo(b.name);
                });

                if (contacts.isEmpty)
                  return const Center(child: Text('Address book is empty'));

                return ContactsList(contacts);
              },
            ),
          ),
        ],
      ),
    );
  }
}
