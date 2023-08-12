import 'package:flutter/material.dart';
import '../../localizations.dart';
import '../../model/addressbook_provider.dart';
import '../../model/coin.dart';
import '../../model/coin_type.dart';
import '../addressbook/contact_edit.dart';
import '../addressbook/contacts_list.dart';
import '../authentification/lock_screen.dart';
import '../../widgets/round_button.dart';
import 'package:provider/provider.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({
    Key key,
    this.coin,
    this.shouldPop = false,
    this.contact,
  }) : super(key: key);

  final Coin coin;
  final bool shouldPop;
  final Contact contact;

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBookPage> {
  AddressBookProvider provider;
  Coin coin;
  bool isSearchOpen = false;
  String searchPhrase = '';

  @override
  void initState() {
    coin = widget.coin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AddressBookProvider>(context);

    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.contact == null
                ? AppLocalizations.of(context).addressBookTitle
                : AppLocalizations.of(context).contactTitle,
            key: const Key('addressbook-title'),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.contact == null) _buildHeader(),
            if (widget.contact == null) _buildActiveFilters(),
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
                    return Center(
                        child: Text(
                            AppLocalizations.of(context).addressBookEmpty));

                  return ContactsList(
                    contacts,
                    shouldPop: widget.shouldPop,
                    coin: coin,
                    contact: widget.contact,
                    searchPhrase: searchPhrase,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: isSearchOpen ? _buildSearchBar() : _buildToolBar(),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: TextField(
            autofocus: true,
            onChanged: (String value) {
              setState(() {
                searchPhrase = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        RoundButton(
          onPressed: () {
            setState(() {
              searchPhrase = '';
              isSearchOpen = false;
            });
          },
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildToolBar() {
    return Row(
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
          child: const Icon(Icons.add),
          key: const Key('add-address-page-button'),
        ),
        const SizedBox(width: 4),
        RoundButton(
          onPressed: () {
            setState(() {
              isSearchOpen = true;
            });
          },
          child: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    if (coin == null) return SizedBox();

    String title = coin.abbr;
    switch (coin.type) {
      case CoinType.smartChain:
        title = 'KMD & SmartChains';
        break;
      case CoinType.erc:
        title = 'ETH & ERC tokens';
        break;
      case CoinType.ubiq:
        title = 'Ubiq';
        break;
      case CoinType.bep:
        title = 'BNB & BEP tokens';
        break;
      case CoinType.zhtlc:
        title = 'ARRR & ZHTLC tokens';
        break;
      case CoinType.sbch:
        title = 'SmartBCH tokens';
        break;
      case CoinType.plg:
        title = 'Polygon & PLG tokens';
        break;
      case CoinType.krc:
        title = 'Kucoin & KRC tokens';
        break;
      case CoinType.ftm:
        title = 'Fantom & FTM tokens';
        break;
      case CoinType.etc:
        title = 'Ethereum Classic';
        break;
      case CoinType.hrc:
        title = 'Harmony & HRC tokens';
        break;
      case CoinType.avx:
        title = 'Avalanche & AVAX tokens';
        break;
      case CoinType.hco:
        title = 'Huobi & HCO tokens';
        break;
      case CoinType.qrc:
        title = 'QTUM & QRC tokens';
        break;
      case CoinType.mvr:
        title = 'Moonriver & MVR tokens';
        break;
      case CoinType.slp:
        title = 'SLP tokens';
        break;
      case CoinType.iris:
        title = 'Iris';
        break;
      case CoinType.cosmos:
        title = 'Cosmos';
        break;
      case CoinType.utxo:
        if (coin.abbr == 'QTUM') title = 'QTUM & QRC tokens';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          AppLocalizations.of(context).addressBookFilter(title),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ),
    );
  }
}
