import 'package:flutter/material.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

// This is a quick hotfix. The designs and UX for this screen are not final.
// TODO: Localise messages and implement finalised UX and designs.

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
  void _launchURL() async => await canLaunchUrlString(
          appConfig.transactionWarningInfoUrl)
      ? await launchUrlString('https://cryptonews.net/news/security/20792248/')
      : throw Exception('Could not launch URL');

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
              _showAddress ? 'Transaction Address:' : 'Transaction Hidden',
            ),
            subtitle: Text(
              _showAddress
                  ? widget.address
                  : 'This transaction was hidden due to a possible phishing attempt.',
              style: Theme.of(context).textTheme.caption,
            ),
            enabled: false,
          ),
          // SizedBox(width: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text('Show Address'),
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
                child: Text('More Info'),
                onPressed: _launchURL,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
