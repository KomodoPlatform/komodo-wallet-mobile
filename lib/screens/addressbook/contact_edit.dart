import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_config/theme_data.dart';
import '../../generic_blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../../model/addressbook_provider.dart';
import '../../model/coin.dart';
import '../../model/coin_type.dart';
import '../addressbook/contact_edit_field.dart';
import '../authentification/lock_screen.dart';
import '../../utils/utils.dart';
import '../../widgets/build_protocol_chip.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_simple_dialog.dart';
import 'package:provider/provider.dart';

class ContactEdit extends StatefulWidget {
  const ContactEdit({Key key, this.contact}) : super(key: key);

  final Contact contact;

  @override
  _ContactEditState createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  Contact _editContact;
  String _hashBeforeEdit;
  AddressBookProvider _provider;
  String _focusOn;

  @override
  void initState() {
    super.initState();
    _editContact = widget.contact != null
        ? Contact.fromJson(widget.contact.toJson())
        : Contact();
    _hashBeforeEdit = jsonEncode(_editContact.toJson());
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AddressBookProvider>(context);

    return WillPopScope(
      onWillPop: () => _exitPage(),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _focusOn = '';
            unfocusEverything();
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
            body: Form(
              key: _formKey,
              autovalidateMode: _autovalidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          ContactEditField(
                            name: 'name',
                            label:
                                AppLocalizations.of(context).contactTitleName,
                            icon: Icon(
                              Icons.account_circle,
                              size: 16,
                            ),
                            value: _editContact.name,
                            removable: false,
                            autofocus:
                                widget.contact == null && _focusOn == null,
                            onChange: (String value) {
                              setState(() {
                                _editContact.name = value;
                              });
                            },
                            validator: (String value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context).emptyName;
                              }

                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          if (_editContact?.addresses?.isEmpty ?? true)
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
                            child: Text(
                                AppLocalizations.of(context).contactCancel),
                          ),
                          TextButton(
                            key: const Key('save-address'),
                            onPressed: _saveContact,
                            child:
                                Text(AppLocalizations.of(context).contactSave),
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
      ),
    );
  }

  Future<bool> _exitPage() async {
    final bool wasEdited = _hashBeforeEdit != jsonEncode(_editContact.toJson());
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

  Future<Widget> _buildAddresses() async {
    if (_editContact.addresses == null || _editContact.addresses.isEmpty)
      return SizedBox();

    final List<Widget> addresses = [];
    final List<Coin> all = (await coins).values.toList();

    for (var abbr in _editContact.addresses.keys) {
      final String value = _editContact.addresses[abbr];

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
            right: 6,
            bottom: 6,
          ),
          icon: abbr == null ? null : _buildCoinIcon(abbr),
          removable: true,
          onChange: (String value) {
            setState(() {
              _editContact.addresses[abbr] = value;
            });
          },
          validator: (String value) {
            if (value.isEmpty) {
              return AppLocalizations.of(context).emptyCoin(abbr);
            }

            return null;
          },
          onRemove: () {
            setState(() {
              _focusOn = '';
              unfocusEverything();
            });
            _editContact.addresses.removeWhere((k, v) => k == abbr);
          },
          autofocus: abbr == _focusOn,
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
      backgroundImage: AssetImage(getCoinIconPath(abbr)),
    );
  }

  Widget _buildAddButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton.icon(
          key: const Key('add-address'),
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
          key: Key('selected-coin-${coin.abbr}'),
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
                BuildProtocolChip(coin)
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
      _focusOn = '';
    });
    unfocusEverything();

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

    final coinsList = _editContact.addresses != null
        ? all
            .where((Coin c) => !_editContact.addresses.containsKey(c.abbr))
            .toList()
        : all;

    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CustomSimpleDialog(
                key: const Key('select-coin-list'),
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
                          hintText:
                              AppLocalizations.of(context).searchForTicker,
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

  void _createAddress(Coin coin) {
    _editContact.addresses ??= {};

    String addressKey;
    if (coin.type == CoinType.smartChain) {
      addressKey = 'KMD';
    } else if (coin.abbr == 'SMTF-v2') {
      // Special case, biz-devs request
      addressKey = 'SMTF-v2';
    } else if (coin.protocol?.protocolData?.platform != null) {
      // All 'children' assets have same address as 'parent' coin
      addressKey = coin.protocol.protocolData.platform;
    } else {
      // All 'parent' coins and UTXO's
      addressKey = coin.abbr;
    }

    setState(() {
      _editContact.addresses[addressKey] ??= '';
      _focusOn = addressKey;
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
          AppLocalizations.of(context).contactDeleteWarning(_editContact.name),
      confirmButtonText: AppLocalizations.of(context).contactDeleteBtn,
      onConfirm: () => _deleteContact(),
    );
  }

  void _deleteContact() {
    if (widget.contact == null) return;
    _provider.deleteContact(widget.contact);
    Navigator.of(context).pop();
  }

  void _saveContact() {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _autovalidate = true;
      });
      return;
    }

    if (widget.contact != null) {
      _provider.updateContact(_editContact);
    } else {
      _provider.createContact(
        name: _editContact.name,
        addresses: _editContact.addresses,
      );
    }

    Navigator.of(context).pop();
  }
}
