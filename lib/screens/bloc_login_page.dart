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
      appBar: AppBar(
        title: Text('Login'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).primaryColor,
              primaryColor: Theme.of(context).accentColor,
              textTheme: Theme.of(context).textTheme),
          child: ListView(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 100,
                        width: 100,
                        child: Image.asset("assets/logo_kmd.png")),
                    SizedBox(height: 50,),
                    Row(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
