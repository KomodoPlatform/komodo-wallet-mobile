import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit_field.dart';
import 'package:komodo_dex/widgets/round_button.dart';

class ContactEdit extends StatefulWidget {
  const ContactEdit({this.contact});

  final Contact contact;

  @override
  _ContactEditState createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  Contact editContact;

  @override
  void initState() {
    editContact = widget.contact ?? Contact();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.contact == null
              ? 'Create Contact' // TODO(yurii): localization
              : 'Edit Contact', // TODO(yurii): localization
          key: const Key('contact_edit-title'),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ContactEditField(
                      name: 'Name',
                      color: Theme.of(context).primaryColor,
                      value: editContact.name,
                      removable: false,
                      autofocus: widget.contact == null,
                      onChange: (String value) {
                        editContact.name = value;
                      }),
                  ContactEditField(
                      name: 'Name',
                      value: editContact.name,
                      removable: false,
                      autofocus: widget.contact == null,
                      onChange: (String value) {
                        editContact.name = value;
                      }),
                  ContactEditField(
                      name: 'Name',
                      value: editContact.name,
                      removable: false,
                      autofocus: widget.contact == null,
                      onChange: (String value) {
                        editContact.name = value;
                      }),
                  ContactEditField(
                      name: 'Name',
                      value: editContact.name,
                      removable: false,
                      autofocus: widget.contact == null,
                      onChange: (String value) {
                        editContact.name = value;
                      }),
                  ContactEditField(
                      name: 'Name',
                      value: editContact.name,
                      removable: false,
                      autofocus: widget.contact == null,
                      onChange: (String value) {
                        editContact.name = value;
                      }),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  onPressed: () {},
                  child: const Text('Cancel'), // TODO(yurii): localization
                ),
                FlatButton(
                  onPressed: () {},
                  child: const Text('Save'), // TODO(yurii): localization
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
