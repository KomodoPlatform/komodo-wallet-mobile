import 'package:flutter/material.dart';
import '../../../../../../blocs/swap_bloc.dart';
import '../../../../../markets/build_order_details.dart';
import '../../../../../../widgets/custom_simple_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../blocs/dialog_bloc.dart';
import '../../../../../../localizations.dart';
import '../../../../../../model/orderbook.dart';
import '../../../../../../widgets/shared_preferences_builder.dart';

void openBidDetailsDialog({
  BuildContext context,
  Ask bid,
  Function onSelect,
}) {
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (context) {
        return SharedPreferencesBuilder<bool>(
            pref: 'showOrderDetailsByTap',
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();

              bool showSettings = false;
              bool showOrderDetailsByTap = snapshot.data;

              return StatefulBuilder(
                builder: (context, setState) {
                  return CustomSimpleDialog(
                    hasHorizontalPadding: false,
                    title: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                            child: Text(AppLocalizations.of(context)
                                .orderDetailsTitle)),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showSettings = !showSettings;
                            });
                          },
                          splashRadius: 16,
                          iconSize: 16,
                          icon: Icon(Icons.settings),
                        ),
                      ],
                    ),
                    children: <Widget>[
                      if (showSettings)
                        SwitchListTile(
                          title: Text(
                            AppLocalizations.of(context).orderDetailsSettings,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          value: showOrderDetailsByTap,
                          onChanged: (bool val) async {
                            (await SharedPreferences.getInstance()).setBool(
                              'showOrderDetailsByTap',
                              val,
                            );
                            setState(() {
                              showOrderDetailsByTap = val;
                            });
                          },
                        ),
                      BuildOrderDetails(
                        bid,
                        sellAmount: swapBloc.amountSell,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              onPressed: () => dialogBloc.closeDialog(context),
                              child: Text(AppLocalizations.of(context)
                                  .orderDetailsCancel),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              key: const Key('confirm-details'),
                              onPressed: () {
                                dialogBloc.closeDialog(context);
                                onSelect();
                              },
                              child: Text(AppLocalizations.of(context)
                                  .orderDetailsSelect),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            });
      }).then((dynamic _) => dialogBloc.dialog = null);
}
