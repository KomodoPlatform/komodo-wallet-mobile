import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(_focus);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Theme.of(context).canvasColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search,
              size: 22,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.search,
                autofocus: true,
                controller: _controller,
                focusNode: _focus,
                maxLength: 50,
                maxLines: 1,
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.bodyText1,
                    labelStyle: Theme.of(context).textTheme.bodyText2,
                    hintText: AppLocalizations.of(context).searchFilterCoin,
                    labelText: null),
                onChanged: (String query) async {
                  isEmptyQuery = query.isEmpty;
                  widget.onFilterCoins(
                      await coinsBloc.getAllNotActiveCoinsWithFilter(query));
                },
              ),
            ),
            InkWell(
              onTap: () {
                if (!isEmptyQuery) {
                  widget.clear();
                  _controller.clear();
                  setState(() {
                    isEmptyQuery = true;
                  });
                } else {
                  FocusScope.of(context).requestFocus(_focus);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: isEmptyQuery
                    ? null
                    : RotationTransition(
                        turns: const AlwaysStoppedAnimation<double>(45 / 360),
                        child: Icon(Icons.add_circle)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
