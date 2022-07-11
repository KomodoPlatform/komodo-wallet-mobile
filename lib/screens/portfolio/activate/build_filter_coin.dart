import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/screens/portfolio/activate/show_protocol_menu.dart'
    as menu;
import 'package:komodo_dex/utils/utils.dart';

class BuildFilterCoin extends StatefulWidget {
  const BuildFilterCoin({
    Key key,
    this.typeFilter,
    this.allCoinsTypes,
    this.onSelected,
  }) : super(key: key);
  final String typeFilter;
  final List<String> allCoinsTypes;
  final Function(String) onSelected;
  @override
  State<BuildFilterCoin> createState() => _BuildFilterCoinState();
}

class _BuildFilterCoinState extends State<BuildFilterCoin> {
  static Map _typesName = {};
  @override
  void initState() {
    readJson();
    super.initState();
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/protocol_names.json');
    _typesName = await json.decode(response);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.0, left: 4),
          child: menu.CustomPopupMenuButton(
            tooltip: 'Filter by Protocols',
            key: const Key('show-filter-protocol'),
            onSelected: widget.onSelected,
            child: Padding(
              padding: EdgeInsets.only(right: 3, left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.typeFilter.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(width: 8),
                  widget.typeFilter != ''
                      ? InkWell(
                          key: const Key('clear-filter-protocol'),
                          onTap: () {
                            widget.onSelected('');
                            focusTextField(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      : Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                ],
              ),
            ),
            itemBuilder: (_) => widget.allCoinsTypes
                .map(
                  (e) => menu.PopupMenuItem<String>(
                    key: Key('filter-item-' + e),
                    value: e,
                    child: Text(
                      _typesName[e] ?? '',
                    ),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}
