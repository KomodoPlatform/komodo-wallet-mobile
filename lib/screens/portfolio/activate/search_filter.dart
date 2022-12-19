import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../blocs/coins_bloc.dart';
import '../../../../localizations.dart';
import '../../../model/coin.dart';

class SearchFieldFilterCoin extends StatefulWidget {
  const SearchFieldFilterCoin({
    Key key,
    this.onFilterCoins,
    this.clear,
    this.type,
    this.controller,
    this.focusNode,
  }) : super(key: key);

  final Function(List<Coin>) onFilterCoins;
  final Function clear;
  final String type;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  _SearchFieldFilterCoinState createState() => _SearchFieldFilterCoinState();
}

class _SearchFieldFilterCoinState extends State<SearchFieldFilterCoin> {
  bool isEmptyQuery = true;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.background;
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(color: color));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).primaryColor,
      ),
      child: TextFormField(
        key: const Key('coins-search-field'),
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        controller: widget.controller,
        focusNode: widget.focusNode,
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
        decoration: InputDecoration(
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          contentPadding: const EdgeInsets.all(0),
          isDense: true,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          hintText: AppLocalizations.of(context).searchFilterCoin,
          fillColor: color,
          filled: true,
          suffixIcon: !isEmptyQuery
              ? IconButton(
                  splashRadius: 24,
                  onPressed: () {
                    widget.clear();
                    widget.controller.clear();
                    setState(() {
                      isEmptyQuery = true;
                    });
                  },
                  icon: RotationTransition(
                    turns: const AlwaysStoppedAnimation<double>(45 / 360),
                    child: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              : null,
        ),
        onChanged: (String query) async {
          isEmptyQuery = query.isEmpty;
          widget.onFilterCoins(await coinsBloc.getAllNotActiveCoinsWithFilter(
              query, widget.type));
        },
      ),
    );
  }
}
