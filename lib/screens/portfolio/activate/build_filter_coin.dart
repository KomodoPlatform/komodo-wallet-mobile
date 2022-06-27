import 'package:flutter/material.dart';

class BuildFilterCoin extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.0, left: 4),
          child: PopupMenuButton(
            tooltip: 'Filter by Protocols',
            key: const Key('show-filter-protocol'),
            onSelected: onSelected,
            child: Padding(
              padding: EdgeInsets.only(right: 3, left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    typeFilter.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(width: 8),
                  typeFilter != ''
                      ? InkWell(
                          key: const Key('clear-filter-protocol'),
                          onTap: () {
                            onSelected('');
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
            itemBuilder: (_) => allCoinsTypes
                .map(
                  (e) => PopupMenuItem<String>(
                    key: Key('filter-item-' + e),
                    value: e,
                    child: Text(
                      e.toUpperCase(),
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
