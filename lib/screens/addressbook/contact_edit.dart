import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit_field.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/confirmation_dialog.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
import 'package:provider/provider.dart';

class ContactEdit extends StatefulWidget {
  const ContactEdit({Key key, this.contact}) : super(key: key);

  final Contact contact;

  @override
  _ContactEditState createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  Contact editContact;
  String hashBeforeEdit;
  AddressBookProvider provider;
  String focusOn;
  final List<String> invalidFields = [];
  Map<String, String> networkChipLabels;

  @override
  void initState() {
    super.initState();
    editContact = widget.contact != null
        ? Contact.fromJson(widget.contact.toJson())
        : Contact();
    hashBeforeEdit = jsonEncode(editContact.toJson());
  }

  @override
  Widget build(BuildContext context) {
    networkChipLabels ??= {
      'erc': AppLocalizations.of(context).tagERC20,
      'bep': AppLocalizations.of(context).tagBEP20,
      'qrc': AppLocalizations.of(context).tagQRC20,
      'plg': AppLocalizations.of(context).tagPLG20,
      'ftm': AppLocalizations.of(context).tagFTM20,
    };

    provider = Provider.of<AddressBookProvider>(context);

    return WillPopScope(
      onWillPop: () => _exitPage(),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            focusOn = '';
            unfocusTextField(context);
          });
        },
        child: LockScreen(
          context: context,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.contact == null
                    ? AppLocalizations.of(context).createContact
                    : AppLocalizations.of(context).editContact,
                key: const Key('contact_edit-title'),
              ),
              actions: <Widget>[
                if (widget.contact != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfiramtion(),
                    splashRadius: 24,
                  ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        ContactEditField(
                          name: 'name',
                          label: AppLocalizations.of(context).contactTitleName,
                          invalid: invalidFields.contains('name'),
                          icon: Icon(
                            Icons.account_circle,
                            size: 16,
                          ),
                          value: editContact.name,
                          removable: false,
                          autofocus: widget.contact == null && focusOn == null,
                          onChange: (String value) {
                            setState(() {
                              editContact.name = value;
                            });
                            _validate();
                          },
                        ),
                        SizedBox(height: 16),
                        _buildAddButton(),
                        FutureBuilder<Widget>(
                          future: _buildAddresses(),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (!snapshot.hasData)
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1),
                                  ),
                                ),
                              );

                            return snapshot.data;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        TextButton(
                          onPressed: _exitPage,
                          child:
                              Text(AppLocalizations.of(context).contactCancel),
                        ),
                        TextButton(
                          onPressed: _saveContact,
                          child: Text(AppLocalizations.of(context).contactSave),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _exitPage() async {
    final bool wasEdited = hashBeforeEdit != jsonEncode(editContact.toJson());
    if (wasEdited) {
      showConfirmationDialog(
          confirmButtonText: AppLocalizations.of(context).contactDiscardBtn,
          context: context,
          icon: Icons.arrow_back,
          title: AppLocalizations.of(context).contactExit,
          message: AppLocalizations.of(context).contactExitWarning,
          onConfirm: () {
            Navigator.of(context).pop();
          });
    } else {
      Navigator.of(context).pop();
    }

    return false;
  }

  bool _validate() {
    setState(() {
      invalidFields.clear();
    });
    bool valid = true;
    if (editContact.name == null || editContact.name.isEmpty) {
      valid = false;
      setState(() {
        invalidFields.add('name');
      });
    }
    editContact.addresses?.forEach((String abbr, String address) {
      if (address.isEmpty) {
        valid = false;
        setState(() {
          invalidFields.add(abbr);
        });
      }
    });

    return valid;
  }

  Future<Widget> _buildAddresses() async {
    if (editContact.addresses == null || editContact.addresses.isEmpty)
      return SizedBox();

    final List<Widget> addresses = [];
    final List<Coin> all = (await coins).values.toList();

    for (var abbr in editContact.addresses.keys) {
      final String value = editContact.addresses[abbr];

      final String name = all
          .firstWhere((Coin coin) => coin.abbr == abbr, orElse: () => null)
          ?.name;

      String label = '$name ($abbr)';
      if (abbr == 'KMD') label = '$name (KMD & SmartChains)';
      if (abbr == 'ETH') label = '$name (ETH & ERC tokens)';
      if (abbr == 'QTUM') label = '$name (QTUM & QRC tokens)';

      addresses.add(
        ContactEditField(
          name: abbr,
          label: name == null ? abbr : label,
          value: value,
          padding: const EdgeInsets.only(
            top: 10,
            left: 16,
            right: 4,
          ),
          icon: abbr == null ? null : _buildCoinIcon(abbr),
          removable: true,
          onChange: (String value) {
            setState(() {
              editContact.addresses[abbr] = value;
            });
            _validate();
          },
          invalid: invalidFields.contains(abbr),
          onRemove: () {
            setState(() {
              focusOn = '';
              unfocusTextField(context);
            });
            editContact.addresses.removeWhere((k, v) => k == abbr);
          },
          autofocus: abbr == focusOn,
        ),
      );
    }

    return Column(
      children: [
        ...addresses,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildAddButton(),
        ),
      ],
    );
  }

  Widget _buildCoinIcon(String abbr) {
    return CircleAvatar(
      maxRadius: 8,
      backgroundImage:
          AssetImage('assets/coin-icons/${getCoinIconPath(abbr)}.png'),
    );
  }

  Widget _buildAddButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: () => _showCoinSelectDialog(),
          style: elevatedButtonSmallButtonStyle(),
          icon: const Icon(Icons.add, size: 16),
          label: Text(AppLocalizations.of(context).addressAdd),
        ),
      ],
    );
  }

  List<SimpleDialogOption> _buildCoinDialogOption(List<Coin> coins) {
    return coins.map(
      (coin) {
        return SimpleDialogOption(
          onPressed: () => _createAddress(coin),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              children: <Widget>[
                _buildCoinIcon(coin.abbr),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    coin.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (networkChipLabels.containsKey(coin.type)) ...{
                  _buildNetworkChip(
                    networkChipLabels[coin.type],
                  )
                } else if (coin.type == 'smartChain') ...{
                  _buildKmdChip()
                }
              ],
            ),
          ),
        );
      },
    ).toList();
  }

  Future<void> _showCoinSelectDialog() async {
    final searchTextController = TextEditingController();

    setState(() {
      focusOn = '';
    });
    unfocusTextField(context);

    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const CustomSimpleDialog(
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          );
        }).then((dynamic _) => dialogBloc.dialog = null);

    final List<Coin> all = (await coins).values.toList();
    all.sort((Coin a, Coin b) => a.name.compareTo(b.name));
    dialogBloc.closeDialog(context);
    await Future<dynamic>.delayed(const Duration(seconds: 0));

    final coinsList = editContact.addresses != null
        ? all
            .where((Coin c) => !editContact.addresses.containsKey(c.abbr))
            .toList()
        : all;

    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CustomSimpleDialog(
                hasHorizontalPadding: false,
                title: Text(AppLocalizations.of(context).addressSelectCoin),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: gefaultUnderlineInputTheme,
                      ),
                      child: TextField(
                        controller: searchTextController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          hintText: 'Search for Ticker',
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                        ],
                      ),
                    ),
                  ),
                  ..._buildCoinDialogOption(
                    filterCoinsByQuery(coinsList, searchTextController.text),
                  ),
                ],
              );
            },
          );
        }).then((dynamic _) => dialogBloc.dialog = null);
  }

  Widget _buildNetworkChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 117, 186, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  Widget _buildKmdChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            maxRadius: 6,
            backgroundImage: AssetImage('assets/coin-icons/kmd.png'),
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).tagKMD,
          ),
        ],
      ),
    );
  }

  void _createAddress(Coin coin) {
    String abbr = coin.abbr;
    editContact.addresses ??= {};

    if (coin.type == 'smartChain') {
      abbr = 'KMD';
    } else if (coin.type == 'erc') {
      abbr = 'ETH';
    } else if (coin.type == 'bep' && coin.abbr != 'SMTF') {
      abbr = 'BNB';
    } else if (coin.type == 'plg') {
      abbr = 'MATIC';
    } else if (coin.type == 'qrc') {
      abbr = 'QTUM';
    } else if (coin.type == 'ftm') {
      abbr = 'FTM';
    }

    setState(() {
      editContact.addresses[abbr] = editContact.addresses[abbr] ?? '';
      focusOn = abbr;
    });
    dialogBloc.closeDialog(context);
  }

  void _showDeleteConfiramtion() {
    showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context).contactDelete,
      icon: Icons.delete,
      iconColor: Theme.of(context).errorColor,
      message:
          AppLocalizations.of(context).contactDeleteWarning(editContact.name),
      confirmButtonText: AppLocalizations.of(context).contactDeleteBtn,
      onConfirm: () => _deleteContact(),
    );
  }

  void _deleteContact() {
    if (widget.contact == null) return;
    provider.deleteContact(widget.contact);
    Navigator.of(context).pop();
  }

  void _saveContact() {
    if (!_validate()) return;

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
