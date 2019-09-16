import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {Key key,
      this.controller,
      this.labelText,
      this.textInputType,
      this.hintText,
      this.onChanged,
      this.errorText})
      : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final TextInputType textInputType;
  final String errorText;
  final String hintText;
  final void Function(String) onChanged;

  @override
  CustomTextFieldState createState() {
    return CustomTextFieldState();
  }
}

class CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      autofocus: false,
      textInputAction: TextInputAction.done,
      keyboardType: widget.textInputType,
      controller: widget.controller,
      style: Theme.of(context).textTheme.body1,
      decoration: InputDecoration(
          errorText: widget.errorText,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColorLight)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor)),
          hintStyle: Theme.of(context).textTheme.body2,
          labelStyle: Theme.of(context).textTheme.body1,
          hintText: widget.hintText,
          labelText: widget.labelText),
    );
  }
}
