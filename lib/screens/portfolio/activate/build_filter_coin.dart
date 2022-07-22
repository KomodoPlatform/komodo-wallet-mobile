import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
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
  final GlobalKey globalKey = GlobalKey();

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
      key: globalKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.0, left: 4),
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
                    : InkWell(
                        onTap: _showMenu,
                        child: Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _showMenu() {
    final RenderBox button =
        globalKey.currentContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay.context.findRenderObject() as RenderBox;
    const Offset offset = Offset.zero;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    dialogBloc.dialog = showMenu(
      context: context,
      position: position,
      items: _buildMenuItem(),
    ).then((value) => dialogBloc.dialog = null);
  }

  List<PopupMenuEntry<String>> _buildMenuItem() {
    return widget.allCoinsTypes.map((String protocolType) {
      return PopupMenuItem<String>(
        key: Key('filter-item-' + protocolType),
        value: protocolType,
        child: Text(
          _typesName[protocolType] ?? '',
        ),
      );
    }).toList();
  }
}
