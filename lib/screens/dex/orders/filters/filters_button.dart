import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/orders/filters/filters.dart';

class FiltersButton extends StatelessWidget {
  const FiltersButton({
    this.text,
    this.onPressed,
    this.activeFilters,
    this.isActive,
  });

  final String text;
  final Function onPressed;
  final ActiveFilters activeFilters;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = activeFilters.anyActive
        ? Theme.of(context).accentColor
        : Theme.of(context).textTheme.bodyText1.color;

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 1.0),
              child: Icon(
                Icons.filter_alt_outlined,
                size: 14,
                color: color,
              ),
            ),
            SizedBox(width: 2),
            Text(
              text ?? 'Filter',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: color,
                  ),
            ),
            if (activeFilters.anyActive)
              Text(
                ' (${activeFilters.matches})',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            Icon(isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
