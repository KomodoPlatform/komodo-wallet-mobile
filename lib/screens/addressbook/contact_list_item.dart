import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit.dart';

class ContactListItem extends StatefulWidget {
  const ContactListItem(this.contact);

  final Contact contact;

  @override
  _ContactListItemState createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.contact.name,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        if (expanded)
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: <Widget>[
                _buildAddressessList(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                        onPressed: () {
                          Navigator.push<dynamic>(
                              context,
                              MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) => ContactEdit(
                                  contact: widget.contact,
                                ),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.edit, size: 16),
                            const SizedBox(width: 4),
                            const Text('Edit'),
                          ],
                        )),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAddressessList() {
    final List<Widget> addresses = [];

    widget.contact.addresses?.forEach((String abbr, String value) {
      addresses.add(
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                maxRadius: 6,
                backgroundImage: AssetImage('assets/${abbr.toLowerCase()}.png'),
              ),
              const SizedBox(width: 4),
              Text(
                '$abbr: ',
                style: const TextStyle(fontSize: 14),
              ),
              Flexible(
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).accentColor,
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
    });

    if (addresses.isEmpty) {
      addresses.add(Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Text(
              'Nothing found',
              style: TextStyle(
                color: Theme.of(context).accentColor,
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
}
