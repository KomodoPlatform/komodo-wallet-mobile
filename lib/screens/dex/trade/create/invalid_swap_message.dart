import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/utils/utils.dart';

class InvalidSwapMessage extends StatefulWidget {
  const InvalidSwapMessage(this.apiErrorMessage);

  final String apiErrorMessage;

  @override
  _InvalidSwapMessageState createState() => _InvalidSwapMessageState();
}

class _InvalidSwapMessageState extends State<InvalidSwapMessage> {
  BuildContext _mainContext;
  String _validatorError;

  @override
  Widget build(BuildContext context) {
    _mainContext = context;

    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width * 4 / 5,
        padding: EdgeInsets.fromLTRB(24, 14, 24, 10),
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
                            .copyWith(color: Colors.orange),
                        children: [
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 2),
                            child: Icon(
                              Icons.open_in_new_rounded,
                              size: 12,
                              color: Colors.orange,
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
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                  RaisedButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(AppLocalizations.of(context).okButton),
                  )
                ],
              );
            });
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
              onTap: () => setState(() => _showDetails = !_showDetails),
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                child: Row(
                  children: [
                    Text(
                      'Show details',
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
                          .then<dynamic>((dynamic _) {
                        Scaffold.of(_mainContext).hideCurrentSnackBar();
                      });
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
          color: Colors.orange,
        ),
      ),
    ]);
  }
}
