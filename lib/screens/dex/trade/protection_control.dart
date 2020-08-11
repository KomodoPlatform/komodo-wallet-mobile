import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
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
  bool useCustom = false;
  bool dpowRequired = false;
  bool dpowAvailable = false;
  final int minConfs = 1;
  final int maxConfs = 5;
  int confs;
  final String dPoWInfoUrl =
      'https://komodoplatform.com/security-delayed-proof-of-work-dpow/';
  final Color warningColor = Colors.red.withAlpha(200);

  @override
  void initState() {
    super.initState();
    setState(() {
      dpowRequired = widget.coin.requiresNotarization;
      confs = widget.coin.requiredConfirmations ?? minConfs;
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
        SizedBox(height: useCustom ? 6 : 0),
        Container(
          color: useCustom ? Theme.of(context).primaryColor : null,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 6,
            bottom: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              useCustom ? _buildConfigs() : _buildDefaults(),
            ],
          ),
        ),
        _buildWarning(),
        _buildToggle(),
      ],
    );
  }

  Widget _buildConfigs() {
    return Column(
      children: <Widget>[
        _buildNotarizaton(),
        Container(
          height: 1,
          color: Theme.of(context).backgroundColor,
        ),
        _buildConfirmations(),
      ],
    );
  }

  Widget _buildDefaults() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border(
        top: BorderSide(
          color: Theme.of(context).highlightColor,
        ),
        bottom: BorderSide(
          color: Theme.of(context).highlightColor,
        ),
      )),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _builddPowLink(),
              ),
              Text(
                // TODO(yurii): localization
                widget.coin.requiresNotarization ? 'ON' : 'OFF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: <Widget>[
              const Expanded(
                  child: Text(
                'Confirmations: ', // TODO(yurii): localization
              )),
              Text(
                widget.coin.requiresNotarization
                    ? 'ON'
                    : widget.coin.requiredConfirmations == null
                        ? '1' // TODO(yurii): localization
                        : widget.coin.requiredConfirmations.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _builddPowLink() {
    return GestureDetector(
      onTap: () {
        launchURL(dPoWInfoUrl);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const Text(
            'Komodo dPoW security ', // TODO(yurii): localization
          ),
          Icon(
            Icons.open_in_new,
            size: 14,
            color: Theme.of(context).accentColor.withAlpha(180),
          ),
          const Text(
            ': ', // TODO(yurii): localization
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              useCustom = !useCustom;
            });
            _onChange();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 8,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  useCustom ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                ),
                const SizedBox(width: 3),
                const Text(
                  // TODO(yurii): localization
                  'Use custom protection settings',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    final bool checkDPow =
        useCustom ? dpowRequired : widget.coin.requiresNotarization;

    if (!dpowAvailable || checkDPow) return Container();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 30,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.warning,
                  color: warningColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  // TODO(yurii): localization
                  'Warning, this atomic swap is not '
                  'dPoW protected. ',
                  style: TextStyle(
                    color: warningColor,
                  ),
                ),
              ),
            ],
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
              Expanded(
                child: _builddPowLink(),
              ), // TODO(yurii): localization
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

  void _onChange() {
    if (widget.onChange == null) return;

    final ProtectionSettings protectionSettings = useCustom
        ? ProtectionSettings(
            requiresNotarization: dpowRequired,
            requiredConfirmations: confs,
          )
        : ProtectionSettings(
            requiredConfirmations: widget.coin.requiredConfirmations,
            requiresNotarization: widget.coin.requiresNotarization,
          );

    widget.onChange(protectionSettings);
  }
}

class ProtectionSettings {
  ProtectionSettings({this.requiresNotarization, this.requiredConfirmations});

  bool requiresNotarization;
  int requiredConfirmations;
}
