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
                          onTap: () {
                            onSelected('');
                          },
                          child: Icon(Icons.close, color: Colors.white),
                        )
                      : Icon(Icons.filter_list, color: Colors.white),
                ],
              ),
            ),
            itemBuilder: (_) => allCoinsTypes
                .map(
                  (e) => PopupMenuItem<String>(
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
