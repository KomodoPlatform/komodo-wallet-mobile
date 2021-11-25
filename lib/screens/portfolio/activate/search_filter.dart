import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';

class SearchFieldFilterCoin extends StatefulWidget {
  const SearchFieldFilterCoin({
    Key key,
    this.onFilterCoins,
    this.clear,
  }) : super(key: key);

  final Function(List<Coin>) onFilterCoins;
  final Function clear;

  @override
  _SearchFieldFilterCoinState createState() => _SearchFieldFilterCoinState();
}

class _SearchFieldFilterCoinState extends State<SearchFieldFilterCoin> {
  final FocusNode _focus = FocusNode();
  bool isEmptyQuery = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).primaryColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        textInputAction: TextInputAction.search,
        autofocus: true,
        controller: _controller,
        focusNode: _focus,
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.search),
          hintText: AppLocalizations.of(context).searchFilterCoin,
          border: InputBorder.none,
          suffixIcon: !isEmptyQuery
              ? IconButton(
                  splashRadius: 24,
                  onPressed: () {
                    widget.clear();
                    _controller.clear();
                    setState(() {
                      isEmptyQuery = true;
                    });
                  },
                  icon: RotationTransition(
                    turns: const AlwaysStoppedAnimation<double>(45 / 360),
                    child: Icon(Icons.add_circle),
                  ),
                )
              : null,
        ),
        onChanged: (String query) async {
          isEmptyQuery = query.isEmpty;
          widget.onFilterCoins(
              await coinsBloc.getAllNotActiveCoinsWithFilter(query));
        },
      ),
    );
  }
}
