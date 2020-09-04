import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final subjectController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: <Widget>[IconButton(icon: Icon(Icons.send), onPressed: _send)],
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: subjectController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Subject',
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          ),
        ],
      ),
    );
  }
}
