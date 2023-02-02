import 'package:flutter/material.dart';
import '../../../generic_blocs/dialog_bloc.dart';
import '../../../app_config/app_config.dart';

class BuildFilterCoin extends StatefulWidget {
  const BuildFilterCoin({
    Key key,
    this.typeFilter,
    this.allCoinsTypes,
    this.onSelected,
    this.focusNode,
  }) : super(key: key);
  final String typeFilter;
  final List<String> allCoinsTypes;
  final Function(String) onSelected;
  final FocusNode focusNode;

  @override
  State<BuildFilterCoin> createState() => _BuildFilterCoinState();
}

class _BuildFilterCoinState extends State<BuildFilterCoin> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _globalKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.0, left: 4),
          child: InkWell(
            key: const Key('show-filter-protocol'),
            onTap: _showMenu,
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
                            widget.focusNode.requestFocus();
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
          ),
        )
      ],
    );
  }

  void _showMenu() {
    final RenderBox button =
        _globalKey.currentContext.findRenderObject() as RenderBox;
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
        onTap: () {
          widget.onSelected(protocolType);
        },
        child: Text(
          appConfig.allProtocolNames[protocolType] ?? '',
        ),
      );
    }).toList();
  }
}
