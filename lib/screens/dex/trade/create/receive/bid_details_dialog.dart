import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/screens/markets/build_order_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';

void openBidDetailsDialog({
  BuildContext context,
  Ask bid,
  Function onSelect,
}) {
  dialogBloc.dialog = showDialog(
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
                  return SimpleDialog(
                    title: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                            child: Text(AppLocalizations.of(context)
                                .orderDetailsTitle)),
                        InkWell(
                          onTap: () {
                            setState(() {
                              showSettings = !showSettings;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.settings,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 4,
                    ),
                    contentPadding: const EdgeInsets.only(
                      left: 8,
                      right: 0,
                      bottom: 20,
                    ),
                    children: <Widget>[
                      if (showSettings)
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 6, 0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .orderDetailsSettings,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Switch(
                                  value: showOrderDetailsByTap,
                                  onChanged: (bool val) async {
                                    (await SharedPreferences.getInstance())
                                        .setBool(
                                      'showOrderDetailsByTap',
                                      val,
                                    );
                                    setState(() {
                                      showOrderDetailsByTap = val;
                                    });
                                  }),
                            ],
                          ),
                        ),
                      BuildOrderDetails(
                        bid,
                        sellAmount: swapBloc.amountSell,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () => dialogBloc.closeDialog(context),
                            child: Text(AppLocalizations.of(context)
                                .orderDetailsCancel),
                          ),
                          const SizedBox(width: 12),
                          RaisedButton(
                            onPressed: () {
                              dialogBloc.closeDialog(context);
                              onSelect();
                            },
                            child: Text(AppLocalizations.of(context)
                                .orderDetailsSelect),
                          )
                        ],
                      )
                    ],
                  );
                },
              );
            });
      });
}
