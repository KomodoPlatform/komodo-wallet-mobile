import 'package:flutter/material.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

// This is a quick hotfix. The designs and UX for this screen are not final.

@immutable
class WarningTransactionListItem extends StatefulWidget {
  const WarningTransactionListItem({@required this.address, Key key})
      : super(key: key);

  final String address;

  @override
  State<WarningTransactionListItem> createState() =>
      _WarningTransactionListItemState();
}

class _WarningTransactionListItemState
    extends State<WarningTransactionListItem> {
  bool _showAddress = false;

  // Function to open URL
  void _launchURL(BuildContext context) async => await canLaunchUrlString(
          appConfig.transactionWarningInfoUrl)
      ? await launchUrlString('https://cryptonews.net/news/security/20792248/')
      : throw Exception(AppLocalizations.of(context).couldNotLaunchUrl);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          SizedBox(height: 4),
          ListTile(
            leading: Icon(
              Icons.warning,
              color: Colors.red,
            ),
            title: Text(
              _showAddress
                  ? '${AppLocalizations.of(context).transactionAddress}:'
                  : AppLocalizations.of(context).transactionHidden,
            ),
            subtitle: Text(
              _showAddress
                  ? widget.address
                  : AppLocalizations.of(context).transactionHiddenPhishing,
              style: Theme.of(context).textTheme.caption,
            ),
            enabled: false,
          ),
          // SizedBox(width: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(AppLocalizations.of(context).showAddress),
                onPressed: _showAddress
                    ? null
                    : () {
                        setState(() {
                          _showAddress = true;
                        });
                      },
              ),
              const SizedBox(width: 8),
              TextButton(
                child: Text(AppLocalizations.of(context).moreInfo),
                onPressed: () => _launchURL(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
