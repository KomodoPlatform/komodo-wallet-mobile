import 'package:flutter/material.dart';

class AddressBookPage extends StatefulWidget {
  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Address Book',
            key: Key('addressbook-title'),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).primaryColor,
              textTheme: Theme.of(context).textTheme),
          child: Container(),
        ));
  }
}
