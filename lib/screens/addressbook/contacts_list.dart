import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_type.dart';
import 'package:komodo_dex/screens/addressbook/contact_list_item.dart';

class ContactsList extends StatefulWidget {
  const ContactsList(
    this.contacts, {
    Key key,
    this.shouldPop = false,
    this.coin,
    this.contact,
    this.searchPhrase,
  }) : super(key: key);

  final List<Contact> contacts;
  final bool shouldPop;
  final Coin coin;
  final Contact contact;
  final String searchPhrase;

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> list = _buildList();

    if (list.isEmpty)
      return Center(
        child: Text(AppLocalizations.of(context).contactNotFound),
      );

    return ListView(
      key: const Key('address-list'),
      children: list,
    );
  }

  List<Widget> _buildList() {
    final List<Widget> list = [];
    final List<Contact> contacts = widget.coin != null
        ? _getContactsContainingCoinAddress()
        : widget.contacts;

    String indexLetter = '';
    List<Widget> indexBlock;

    for (Contact contact in contacts) {
      if (widget.contact != null && contact != widget.contact) {
        continue;
      }

      if (widget.searchPhrase != null && !_isRelevant(contact)) {
        continue;
      }

      final bool shouldCreateBlock =
          contact.name[0] != indexLetter || widget.searchPhrase != '';

      if (shouldCreateBlock) {
        indexLetter = contact.name[0];
        _addBlockToList(indexBlock, list);
        indexBlock = [];

        final bool needIndexes =
            widget.contact == null && widget.searchPhrase == '';

        if (needIndexes) {
          list.add(
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                indexLetter,
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
          );
        }
      }

      indexBlock.add(ContactListItem(
        contact,
        shouldPop: widget.shouldPop,
        coin: widget.coin,
        expanded: widget.contact != null,
      ));
    }

    _addBlockToList(indexBlock, list);

    return list;
  }

  List<Contact> _getContactsContainingCoinAddress() {
    final Coin coin = widget.coin;
    if (coin == null) return widget.contacts;

    return widget.contacts.where((contact) {
      if (contact.addresses == null || contact.addresses.isEmpty) {
        return false;
      }
      if (contact.addresses.containsKey(coin.abbr)) {
        return true;
      }

      if (coin.type == CoinType.smartChain &&
          contact.addresses.containsKey('KMD')) {
        return true;
      }

      final String platform = coin.protocol?.protocolData?.platform;
      if (platform != null && contact.addresses.containsKey(platform)) {
        return true;
      }

      return false;
    }).toList();
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
            color: Theme.of(context).primaryColor,
          ),
        );
      }
    }

    list.add(
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: widget.searchPhrase == '' ? 16 : 4,
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: blockList,
          ),
        ),
      ),
    );
  }

  bool _isRelevant(Contact contact) {
    return contact.name
        .toLowerCase()
        .contains(widget.searchPhrase.toLowerCase());
  }
}
