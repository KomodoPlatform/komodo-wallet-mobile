import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/screens/addressbook/contact_list_item.dart';

class ContactsList extends StatefulWidget {
  const ContactsList(
    this.contacts, {
    this.shouldPop = false,
    this.filter,
  });

  final List<Contact> contacts;
  final bool shouldPop;
  final String filter;

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> list = _buildList();

    if (list.isEmpty)
      return const Center(
        child: Text('No contacts found'), // TODO(yurii): localization
      );

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      ),
    );
  }

  List<Widget> _buildList() {
    final List<Widget> list = [];
    final List<Contact> filteredContacts = widget.contacts.where(
      (Contact contact) {
        if (widget.filter == null || widget.filter.isEmpty) {
          return true;
        }
        if (contact.addresses == null || contact.addresses.isEmpty) {
          return false;
        }
        if (contact.addresses.containsKey(widget.filter)) {
          return true;
        }
        return false;
      },
    ).toList();

    String indexLetter = '';
    List<Widget> indexBlock;

    for (Contact contact in filteredContacts) {
      if (contact.name[0] != indexLetter) {
        indexLetter = contact.name[0];
        _addBlockToList(indexBlock, list);
        list.add(
          Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: Text(
              indexLetter,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        indexBlock = [];
      }
      indexBlock.add(ContactListItem(
        contact,
        shouldPop: widget.shouldPop,
        filter: widget.filter,
      ));
    }

    _addBlockToList(indexBlock, list);

    return list;
  }

  void _addBlockToList(List<Widget> block, List<Widget> list) {
    if (block == null || block.isEmpty) return;

    final List<Widget> blockList = [];

    for (int i = 0; i < block.length; i++) {
      final Widget contact = block[i];
      blockList.add(contact);
      if (i < block.length - 1) {
        blockList.add(
          Divider(
            indent: 10,
            endIndent: 10,
            height: 1,
            color: Theme.of(context).primaryColorLight,
          ),
        );
      }
    }

    list.add(
      Padding(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
        ),
        child: Card(
          margin: const EdgeInsets.all(0),
          elevation: 3,
          color: Theme.of(context).primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: blockList,
          ),
        ),
      ),
    );
  }
}
