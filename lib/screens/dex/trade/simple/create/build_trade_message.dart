import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:provider/provider.dart';

class BuildTradeMessage extends StatefulWidget {
  @override
  _BuildTradeMessageState createState() => _BuildTradeMessageState();
}

class _BuildTradeMessageState extends State<BuildTradeMessage> {
  ConstructorProvider _constrProvider;
  String _error;
  String _warning;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _error = _constrProvider.error;
    _warning = _constrProvider.warning;

    if (_constrProvider.matchingOrder == null &&
        _error == null &&
        _warning == null) return SizedBox();

    return Container(
      padding: EdgeInsets.fromLTRB(12, 4, 12, 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 34),
        child: Container(
          //color: Colors.yellow,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error == null && _warning == null) return SizedBox();

    return _error == null ? _buildWarning() : _buildError();
  }

  Widget _buildWarning() {
    final Color color = Theme.of(context).textTheme.bodyText1.color;

    return Container(
      padding: EdgeInsets.fromLTRB(6, 4, 0, 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 0.5)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _warning,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: color, height: 1),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: Icon(
                Icons.clear,
                size: 13,
                color: color,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildError() {
    final Color color = Theme.of(context).errorColor;

    return Container(
      padding: EdgeInsets.fromLTRB(6, 4, 0, 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 0.5)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _error,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: color, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
