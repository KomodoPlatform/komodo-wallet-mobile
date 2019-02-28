import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final Key key;
  final TextEditingController controller;
  final String labelText;
  final TextInputType textInputType;

  @override
  CustomTextFieldState createState() {
    return new CustomTextFieldState();
  }

  const CustomTextField(
      {this.key, this.controller, this.labelText, this.textInputType})
      : super(key: key);
}

class CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      textInputAction: TextInputAction.done,
      keyboardType: widget.textInputType,
      controller: widget.controller,
      style: Theme.of(context).textTheme.body1,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColorLight)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor)),
          hintStyle: Theme.of(context).textTheme.body1,
          labelStyle: Theme.of(context).textTheme.body1,
          labelText: widget.labelText),
    );
  }
}
