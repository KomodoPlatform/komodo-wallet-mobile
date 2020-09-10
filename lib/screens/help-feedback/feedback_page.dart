import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final subjectController = TextEditingController();
  final emailAddressController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<void> _send() async {
    // TODO(MateusRodCosta): Fill with actual login deatils

    const username = '******';
    const password = '******';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.

    const recipientAddress = '******';
    // TODO(MateusRodCosta): Add user email to the message

    final message = Message()
      ..from = Address(username, 'AtomicDEX test')
      ..recipients.add(recipientAddress)
      ..subject = subjectController.text
      ..text = descriptionController.text;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    emailAddressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        actions: <Widget>[IconButton(icon: Icon(Icons.send), onPressed: _send)],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          TextField(
            controller: subjectController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Subject',
            ),
          ),
          TextField(
            controller: emailAddressController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Email Address',
            ),
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: null,
              maxLines: null,
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
              ),
            ),
          ),
          Text('For your convenience logs will be attached'),
        ],
      ),
    );
  }
}
