import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/widgets/custom_textfield.dart';

class BlocLoginPage extends StatefulWidget {
  @override
  _BlocLoginPageState createState() => _BlocLoginPageState();
}

class _BlocLoginPageState extends State<BlocLoginPage> {
  final passphraseTxtFldCtlr = TextEditingController();

  @override
  void dispose() {
    passphraseTxtFldCtlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: Container(
        child: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).primaryColor,
              primaryColor: Theme.of(context).accentColor,
              textTheme: Theme.of(context).textTheme),
          child: Row(
            children: <Widget>[
              Expanded(
                child: CustomTextField(
                  controller: passphraseTxtFldCtlr,
                  labelText: 'Passphrase',
                  textInputType: TextInputType.text,
                ),
              ),
              MaterialButton(
                  child: Text("LOGIN"),
                  onPressed: () {
                    authBloc.login(passphraseTxtFldCtlr.text);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
