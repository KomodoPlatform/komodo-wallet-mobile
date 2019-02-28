import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';

class ConfirmAccountPage extends StatefulWidget {
  final String seed;

  ConfirmAccountPage(this.seed);

  @override
  _ConfirmAccountPageState createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  TextEditingController controllerSeed = new TextEditingController();
  bool _isButtonDisabled;

  @override
  void dispose() {
    controllerSeed.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _isButtonDisabled = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Confirm Seed'),
        ),
        body: Column(
          children: <Widget>[
            _buildTitle(),
            _buildInputSeed(),
            _buildConfirmButton(),
          ],
        ));
  }

  _buildTitle() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 56,
        ),
        Center(
          child: Text(
            'Enter Your Seed Phrase',
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 56,
        ),
      ],
    );
  }

  _buildInputSeed() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controllerSeed,
        onChanged: (str) {
          if (str == widget.seed) {
            setState(() {
              _isButtonDisabled = false;
            });
          } else {
            setState(() {
              _isButtonDisabled = true;
            });
          }
        },
        autocorrect: false,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: Theme.of(context).textTheme.body1,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            hintStyle: Theme.of(context).textTheme.body2,
            labelStyle: Theme.of(context).textTheme.body1,
            hintText: 'Example: over cake age ...',
            labelText: null),
      ),
    );
  }

  _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        height: 50,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
          color: Theme.of(context).buttonColor,
          disabledColor: Theme.of(context).disabledColor,
          child: Text(
            'CONFIRM',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: _isButtonDisabled ? null : _onLoginPressed,
        ),
      ),
    );
  }

  _onLoginPressed() {
    Navigator.pop(context);
    Navigator.pop(context);
    authBloc.login(controllerSeed.text);
  }
}
