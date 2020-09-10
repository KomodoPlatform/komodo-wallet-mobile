import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/help-feedback/feedback_page.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  Widget _buildSocialPlatform(
      {IconData icon = Icons.check_circle, String text}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Icon(icon),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help and Feedback'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                'Frequent Asked Questions',
                softWrap: true,
              ),
            ),
          ),
          Text('Connect with us also on'),
          Row(
            children: <Widget>[
              _buildSocialPlatform(text: 'Discord'),
              _buildSocialPlatform(text: 'Twitter'),
            ],
          ),
          RaisedButton(
            child: Text('Send Feedback'),
            onPressed: () {
              Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => FeedbackPage()));
            },
          ),
        ],
      ),
    );
  }
}
