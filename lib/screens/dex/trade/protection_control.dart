import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:provider/provider.dart';

class ProtectionControl extends StatefulWidget {
  const ProtectionControl({
    @required this.coinBase,
    @required this.coinRel,
  });

  final Coin coinBase;
  final Coin coinRel;

  @override
  _ProtectionControlState createState() => _ProtectionControlState();
}

class _ProtectionControlState extends State<ProtectionControl> {
  final int recommendedConfirmations = 3;
  int confirmations;
  bool isSliderActive = false;
  bool useDefaults = true;

  @override
  void initState() {
    super.initState();
    confirmations = recommendedConfirmations;
  }

  @override
  Widget build(BuildContext context) {
    final SwapProvider swapProvider = Provider.of<SwapProvider>(context);
    final defaultNota = widget.coinBase.requiresNotarization;

    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Protection settings:',
            style: Theme.of(context).textTheme.body2,
          ),
          const SizedBox(height: 6),
          _buildDefaults(),
          const SizedBox(height: 4),
          _buildCustomToggle(),
          if (!useDefaults)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(width: 13),
                    Text('Confirmations: ', // TODO(yurii): localization
                        style: Theme.of(context).textTheme.body2),
                    const SizedBox(width: 4),
                    _buildConfirmationsButton(),
                  ],
                ),
              ],
            ),
          _buildSlider(),
        ],
      ),
    );
  }

  Widget _buildCustomToggle() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            useDefaults = !useDefaults;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(
                useDefaults ? Icons.check_box_outline_blank : Icons.check_box,
                size: 20,
              ),
              const SizedBox(width: 4),
              const Text('Use custom settings'), // TODO(yurii): localization
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaults() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Notarization: '), // TODO(yurii): localization
              Text(
                // TODO(yurii): localization
                widget.coinBase.requiresNotarization ? 'Enabled' : 'Disabled',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 2),
          Row(children: <Widget>[
            const Text('Confirmations: '),
            Text(
              // TODO(yurii): localization
              widget.coinBase.requiredConfirmations.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildConfirmationsButton() {
    return InkWell(
      onTap: () {
        setState(() {
          isSliderActive = !isSliderActive;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 0, top: 8, bottom: 8),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: isSliderActive ? 2 : 1,
                  color: isSliderActive
                      ? Theme.of(context).accentColor
                      : Theme.of(context).primaryColorLight)),
        ),
        child: Row(
          children: <Widget>[
            Text(confirmations.toString(),
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Icon(Icons.unfold_more, size: 16)
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return isSliderActive
        ? SliderTheme(
            data: SliderTheme.of(context).copyWith(
                valueIndicatorTextStyle:
                    TextStyle(color: Theme.of(context).backgroundColor)),
            child: Slider(
                activeColor: Theme.of(context).accentColor,
                divisions: 4,
                label: confirmations == recommendedConfirmations
                    ? '${confirmations.toString()} (recommended)' // TODO(yurii): localization
                    : confirmations.toString(),
                min: 1,
                max: 5,
                value: confirmations.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    confirmations = value.round();
                  });
                }),
          )
        : Container();
  }
}
