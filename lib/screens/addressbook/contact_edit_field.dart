import 'package:flutter/material.dart';

class ContactEditField extends StatefulWidget {
  const ContactEditField({
    @required this.name,
    this.value,
    this.removable = false,
    this.autofocus = false,
    this.onChange,
    this.color,
  });

  final bool autofocus;
  final bool removable;
  final String name;
  final String value;
  final Color color;
  final Function(String) onChange;

  @override
  _ContactEditFieldState createState() => _ContactEditFieldState();
}

class _ContactEditFieldState extends State<ContactEditField> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    if (widget.value != null) {
      controller.text = widget.value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Card(
                margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                color: widget.color ?? Theme.of(context).backgroundColor,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${widget.name}:',
                        style: Theme.of(context).textTheme.body2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: widget.autofocus,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (String value) {
                          if (widget.onChange == null) return;
                          widget.onChange(value);
                        },
                        autocorrect: false,
                        enableInteractiveSelection: true,
                        style: Theme.of(context).textTheme.body1,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).backgroundColor,
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorLight)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).accentColor)),
                          hintStyle: Theme.of(context).textTheme.body2,
                          labelStyle: Theme.of(context).textTheme.body1,
                          labelText: null,
                        ),
                      ),
                    ],
                  ),
                ))),
      ],
    );
  }
}
