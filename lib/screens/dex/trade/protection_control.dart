import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:provider/provider.dart';

class ProtectionControl extends StatefulWidget {
  const ProtectionControl({
    @required this.coin,
    this.onChange,
  });

  final Coin coin;
  final Function(ProtectionSettings) onChange;

  @override
  _ProtectionControlState createState() => _ProtectionControlState();
}

class _ProtectionControlState extends State<ProtectionControl> {
  SwapProvider swapProvider;
  bool dpowRequired = false;
  bool dpowAvailable = false;
  final int minConfs = 0;
  final int maxConfs = 5;
  int confs;

  @override
  void initState() {
    super.initState();
    setState(() {
      dpowRequired = widget.coin.requiresNotarization;
      confs = widget.coin.requiredConfirmations ?? 0;
      if (confs < minConfs) confs = minConfs;
      if (confs > maxConfs) confs = maxConfs;
    });
  }

  @override
  Widget build(BuildContext context) {
    swapProvider = Provider.of<SwapProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        dpowAvailable = swapProvider.notarizationAvailable(widget.coin);
      });
    });

    return Column(
      children: <Widget>[
        Text(
          'Protection settings:',
          style: Theme.of(context).textTheme.body2,
        ),
        const SizedBox(height: 6),
        Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 6,
            bottom: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildNotarizaton(),
              Container(
                height: 2,
                color: Theme.of(context).backgroundColor,
              ),
              _buildConfirmations(),
              _buildWarning(),
            ],
          ),
        ),
      ],
    );
  }

  void _onChange() {
    if (widget.onChange != null) {
      widget.onChange(ProtectionSettings(
        requiresNotarization: dpowRequired,
        requiredConfirmations: confs,
      ));
    }
  }

  Widget _buildWarning() {
    if (dpowRequired || confs > 0) return Container();

    return Column(
      children: <Widget>[
        Container(
          height: 2,
          color: Theme.of(context).backgroundColor,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            // TODO(yurii): localization
            'Warning, this atomic swap is not '
            'dPoW/blockchain confirmation protected.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red.withAlpha(200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotarizaton() {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                  child: Text(
                'Notarization: ',
              )), // TODO(yurii): localization
              Opacity(
                opacity: dpowAvailable ? 1 : 0.5,
                child: Switch(
                  onChanged: dpowAvailable
                      ? (bool value) {
                          setState(() {
                            dpowRequired = value;
                          });
                          _onChange();
                        }
                      : null,
                  value: dpowRequired,
                  inactiveThumbColor:
                      dpowAvailable ? null : Theme.of(context).highlightColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmations() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            left: 8,
            right: 12,
            top: 15,
            bottom: 15,
          ),
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Text('Confirmations:'), // TODO(yurii): localization
              ),
              dpowRequired
                  ? Text(
                      'ON', // TODO(yurii): localization
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      confs.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
            ],
          ),
        ),
        if (!dpowRequired) _buildSlider(),
      ],
    );
  }

  Widget _buildSlider() {
    return Container(
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          valueIndicatorTextStyle:
              TextStyle(color: Theme.of(context).backgroundColor),
        ),
        child: Slider(
            activeColor: Theme.of(context).accentColor,
            divisions: maxConfs - minConfs,
            label: confs.toString(),
            min: minConfs.toDouble(),
            max: maxConfs.toDouble(),
            value: confs.toDouble(),
            onChanged: (double value) {
              setState(() {
                confs = value.round();
              });
              _onChange();
            }),
      ),
    );
  }
}

class ProtectionSettings {
  ProtectionSettings({this.requiresNotarization, this.requiredConfirmations});

  bool requiresNotarization;
  int requiredConfirmations;
}
