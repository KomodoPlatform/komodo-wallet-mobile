import 'package:flutter/material.dart';
import '../../../../localizations.dart';
import '../../../dex/orders/filters/filters.dart';

class FiltersButton extends StatelessWidget {
  const FiltersButton({
    this.text,
    this.onPressed,
    this.activeFilters,
    this.isActive,
  });

  final String? text;
  final Function? onPressed;
  final ActiveFilters? activeFilters;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    final Color? color = activeFilters!.anyActive
        ? Theme.of(context).colorScheme.secondary
        : null;

    return InkWell(
      onTap: onPressed as void Function()?,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 1.0),
              child: Icon(
                Icons.filter_alt_outlined,
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              text ?? AppLocalizations.of(context)!.filtersButton,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: color,
                  ),
            ),
            if (activeFilters!.anyActive)
              Text(
                ' (${activeFilters!.matches})',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            Icon(isActive! ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
