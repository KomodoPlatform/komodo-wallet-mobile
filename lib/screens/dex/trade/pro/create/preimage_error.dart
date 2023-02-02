import 'package:flutter/material.dart';
import '../../../../../generic_blocs/dialog_bloc.dart';
import '../../../../../localizations.dart';
import '../../../../dex/trade/pro/create/trade_form_validator.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_simple_dialog.dart';

class PreimageError extends StatefulWidget {
  const PreimageError(this.apiErrorMessage);

  final String apiErrorMessage;

  @override
  _PreimageErrorState createState() => _PreimageErrorState();
}

class _PreimageErrorState extends State<PreimageError> {
  BuildContext _mainContext;
  String _validatorError;

  @override
  Widget build(BuildContext context) {
    _mainContext = context;

    return InkWell(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 4 / 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
                future: TradeFormValidator().errorMessage,
                builder: (context, snapshot) {
                  _validatorError =
                      snapshot.data ?? AppLocalizations.of(context).invalidSwap;

                  return Flexible(
                      child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: _validatorError,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Theme.of(context).errorColor),
                        children: [
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 2),
                            child: Icon(
                              Icons.open_in_new_rounded,
                              size: 12,
                              color: Theme.of(context).errorColor,
                            ),
                          ))
                        ]),
                  ));
                }),
            SizedBox(width: 2),
          ],
        ),
      ),
      onTap: () async {
        dialogBloc.dialog = showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return CustomSimpleDialog(
                title: Text(AppLocalizations.of(context).invalidSwap,
                    style: TextStyle(fontSize: 18)),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _builValidatorMessage(),
                      _buildApiErrorMessage(widget.apiErrorMessage),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context).okButton),
                      ),
                    ],
                  )
                ],
              );
            }).then((dynamic _) => dialogBloc.dialog = null);
      },
    );
  }

  Widget _buildApiErrorMessage(String message) {
    if (message == null) return SizedBox();

    bool _showDetails = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            SizedBox(height: 6),
            InkWell(
              onTap: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).showDetails,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Icon(
                      _showDetails
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: Theme.of(context).textTheme.bodyText1.color,
                      size: 16,
                    )
                  ],
                ),
              ),
            ),
            if (_showDetails)
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      copyToClipBoard(_mainContext, widget.apiErrorMessage);
                      Future<dynamic>.delayed(Duration(seconds: 2))
                          .then<dynamic>(
                        (dynamic _) {
                          ScaffoldMessenger.of(_mainContext)
                              .hideCurrentSnackBar();
                        },
                      );
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.apiErrorMessage +
                              widget.apiErrorMessage +
                              widget.apiErrorMessage +
                              widget.apiErrorMessage,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _builValidatorMessage() {
    return Column(children: [
      Text(
        _validatorError,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).errorColor,
        ),
      ),
    ]);
  }
}
