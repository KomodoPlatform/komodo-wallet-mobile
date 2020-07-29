import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit_field.dart';
import 'package:komodo_dex/widgets/confirmation_dialog.dart';
import 'package:komodo_dex/widgets/small_button.dart';
import 'package:provider/provider.dart';

class ContactEdit extends StatefulWidget {
  const ContactEdit({this.contact});

  final Contact contact;

  @override
  _ContactEditState createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  Contact editContact;
  int hashBeforeEdit;
  AddressBookProvider provider;
  String focusOn;

  @override
  void initState() {
    editContact = widget.contact ?? Contact();
    hashBeforeEdit = editContact.hashCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AddressBookProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.contact == null
              ? 'Create Contact' // TODO(yurii): localization
              : 'Edit Contact', // TODO(yurii): localization
          key: const Key('contact_edit-title'),
        ),
        actions: <Widget>[
          if (widget.contact != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteConfiramtion(),
            ),
        ],
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
                      label: 'Name',
                      icon: Icon(
                        Icons.account_circle,
                        size: 16,
                        color: Theme.of(context).textTheme.body2.color,
                      ),
                      color: Theme.of(context).primaryColor,
                      value: editContact.name,
                      removable: false,
                      autofocus: widget.contact == null && focusOn == null,
                      onChange: (String value) {
                        editContact.name = value;
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildAddButton(),
                  ),
                  FutureBuilder<Widget>(
                    future: _buildAddresses(),
                    builder:
                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (!snapshot.hasData) return Container();
                      return snapshot.data;
                    },
                  ),
                  if (editContact.addresses != null &&
                      editContact.addresses.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: _buildAddButton(),
                    ),
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
                  onPressed: () {
                    _saveContact();
                  },
                  child: const Text('Save'), // TODO(yurii): localization
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildAddresses() async {
    final List<Widget> addresses = [];

    editContact.addresses?.forEach((String abbr, dynamic value) async {
      final List<Coin> coins = await coinsBloc.electrumCoins();
      final String name = coins
          .firstWhere((Coin coin) => coin.abbr == abbr, orElse: null)
          ?.name;

      addresses.add(
        ContactEditField(
          label: name == null ? '$abbr' : '$name ($abbr)',
          value: value,
          padding: const EdgeInsets.only(
            top: 10,
            left: 16,
            right: 4,
          ),
          icon: abbr == null ? null : _buildCoinIcon(abbr),
          removable: true,
          onChange: (String value) {
            editContact.addresses[abbr] = value;
          },
          onRemove: () {
            setState(() {
              focusOn = '';
              FocusScope.of(context).requestFocus(FocusNode());
            });
            showConfirmationDialog(
              context: context,
              title: 'Remove',
              confirmButtonText: 'Remove', // TODO(yurii): localization
              icon: Icons.remove_circle,
              message:
                  'Are you sure you want to remove ${name ?? ''} address?', // TODO(yurii): localization
              onConfirm: () {
                editContact.addresses.removeWhere((k, v) => k == abbr);
              },
            );
          },
          autofocus: abbr == focusOn,
        ),
      );
    });

    return Column(children: addresses);
  }

  Widget _buildCoinIcon(String abbr) {
    return CircleAvatar(
      maxRadius: 8,
      backgroundImage: AssetImage('assets/${abbr.toLowerCase()}.png'),
    );
  }

  Widget _buildAddButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SmallButton(
          onPressed: () {
            _showAddressSelectDialog();
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.add, size: 16),
              const Text('Add Address'), // TODO(yurii): localization
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddressSelectDialog() async {
    setState(() {
      focusOn = '';
    });
    FocusScope.of(context).requestFocus(FocusNode());

    final List<Coin> elCoins = await coinsBloc.electrumCoins();
    final List<Coin> coins = List.from(elCoins);
    coins.sort((Coin a, Coin b) => a.name.compareTo(b.name));
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          final List<SimpleDialogOption> coinsList = [];
          for (Coin coin in coins) {
            coinsList.add(SimpleDialogOption(
              onPressed: () {
                setState(() {
                  focusOn = coin.abbr;
                  editContact.addresses ??= {};
                  editContact.addresses[coin.abbr] = '';
                });
                dialogBloc.closeDialog(context);
              },
              child: Row(
                children: <Widget>[
                  _buildCoinIcon(coin.abbr),
                  const SizedBox(width: 4),
                  Text(coin.name),
                ],
              ),
            ));
          }

          return SimpleDialog(
            title: const Text('Select Coin'), // TODO(yurii): localization
            children: [
              ...coinsList,
            ],
          );
        });
  }

  void _showDeleteConfiramtion() {
    showConfirmationDialog(
      context: context,
      title: 'Delete Contact', // TODO(yurii): localization
      icon: Icons.delete,
      message:
          'Are you sure you want to delete contact ${editContact.name}?', // TODO(yurii): localization
      confirmButtonText: 'Delete', // TODO(yurii): localization
      onConfirm: () => _deleteContact(),
    );
  }

  void _deleteContact() {
    if (widget.contact == null) return;
    provider.deleteContact(widget.contact);
    Navigator.of(context).pop();
  }

  void _saveContact() {
    if (editContact.name == null || editContact.name.isEmpty) {
      // invalid name
      return;
    }

    if (widget.contact != null) {
      provider.updateContact(editContact);
    } else {
      provider.createContact(
        name: editContact.name,
        addresses: editContact.addresses,
      );
    }

    Navigator.of(context).pop();
  }
}
