import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
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
          'Address Book',
          key: Key('addressbook-title'),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: provider.contacts,
        builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.isEmpty)
            return const Center(child: Text('Address book is empty'));

          return Text(snapshot.data.length.toString());
        },
      ),
    );
  }
}
