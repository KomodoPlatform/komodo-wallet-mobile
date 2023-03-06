import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/iterable_utils.dart';
import 'package:provider/provider.dart';

import '../../generic_blocs/coins_bloc.dart';
import '../../generic_blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../../model/addressbook_provider.dart';
import '../../model/coin.dart';
import '../../model/coin_balance.dart';
import '../../model/coin_type.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_simple_dialog.dart';
import '../addressbook/contact_edit.dart';
import '../portfolio/coin_detail/coin_detail.dart';

class ContactListItem extends StatefulWidget {
  const ContactListItem(
    this.contact, {
    Key? key,
    this.shouldPop = false,
    this.coin,
    this.expanded = false,
  }) : super(key: key);

  final Contact contact;
  final bool shouldPop;
  final Coin? coin;
  final bool expanded;

  @override
  _ContactListItemState createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem> {
  bool expanded = false;
  late AddressBookProvider addressBookProvider;

  @override
  void initState() {
    expanded = widget.expanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addressBookProvider = Provider.of<AddressBookProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          key: Key('address-item-${widget.contact.name}'),
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          title: Text(
            widget.contact.name!,
            key: Key(widget.contact.name!),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: <Widget>[
                _buildAddressesList(),
                SizedBox(height: 8),
                TextButton.icon(
                  key: Key('edit-address-${widget.contact.name}'),
                  onPressed: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          ContactEdit(contact: widget.contact),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(AppLocalizations.of(context)!.contactEdit),
                )
              ],
            ),
          ),
      ],
    );
  }

  String? _getCoinTypeAbbr() {
    if (widget.coin!.type == CoinType.smartChain) return 'KMD';

    final String? platform = widget.coin!.protocol?.protocolData?.platform;
    return platform ?? widget.coin!.abbr;
  }

  Widget _buildAddressesList() {
    final List<Widget> addresses = [];

    widget.contact.addresses?.forEach(
      (String? abbr, String value) {
        if (widget.coin != null && _getCoinTypeAbbr() != abbr) return;

        addresses.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 6,
                  foregroundImage: AssetImage(getCoinIconPath(abbr)),
                ),
                const SizedBox(width: 8),
                Text(
                  '$abbr: ',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Flexible(
                  child: InkWell(
                    onTap: () => _tryToSend(abbr, value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: truncateMiddle(
                              value,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (addresses.isEmpty) {
      addresses.add(Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.addressNotFound,
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ));
    }

    return Column(
      children: addresses,
    );
  }

  void _tryToSend(String? abbr, String value) {
    final CoinBalance? coinBalance = coinsBloc.coinBalance.firstWhereOrNull(
      (CoinBalance balance) {
        return balance.coin!.abbr == abbr;
      },
    );
    if (widget.coin == null && coinBalance == null) {
      _showWarning(
        title: AppLocalizations.of(context)!.noSuchCoin,
        message: AppLocalizations.of(context)!.addressCoinInactive(abbr!),
      );
      return;
    }

    addressBookProvider.clipboard = value;
    if (widget.shouldPop) {
      Navigator.of(context).pop();
    } else {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => CoinDetail(
              coinBalance: coinBalance!,
              isSendIsActive: true,
            ),
          ));
    }
  }

  void _showWarning({String? title, String? message}) {
    dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomSimpleDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.warning),
              const SizedBox(width: 8),
              Text(title!),
            ],
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                    child: Text(
                  message!,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    height: 1.4,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => dialogBloc.closeDialog(context),
                  child: Text(AppLocalizations.of(context)!.warningOkBtn),
                ),
              ],
            ),
          ],
        );
      },
    ).then((dynamic _) => dialogBloc.dialog = null);
  }
}
