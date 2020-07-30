import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/round_button.dart';

class ContactEditField extends StatefulWidget {
  const ContactEditField({
    this.name,
    this.label,
    this.value,
    this.removable = false,
    this.autofocus = false,
    this.onChange,
    this.onRemove,
    this.color,
    this.padding,
    this.icon,
    this.invalid = false,
  });

  final String name;
  final bool autofocus;
  final bool removable;
  final String label;
  final String value;
  final Color color;
  final Function(String) onChange;
  final Function onRemove;
  final EdgeInsets padding;
  final Widget icon;
  final bool invalid;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autofocus) focusNode.requestFocus();
    });

    return Row(
      children: <Widget>[
        Expanded(
            child: Card(
                margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                color: widget.color ?? Theme.of(context).backgroundColor,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (widget.icon != null)
                            Row(
                              children: <Widget>[
                                widget.icon,
                                const SizedBox(width: 4),
                              ],
                            ),
                          Text(
                            '${widget.label}:',
                            style: Theme.of(context).textTheme.body2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
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
                                        color: widget.invalid
                                            ? Colors.red
                                            : Theme.of(context)
                                                .primaryColorLight)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: widget.invalid
                                            ? Colors.red
                                            : Theme.of(context).accentColor)),
                                hintStyle: Theme.of(context).textTheme.body2,
                                labelStyle: Theme.of(context).textTheme.body1,
                                labelText: null,
                              ),
                            ),
                          ),
                          if (widget.removable)
                            Container(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              child: RoundButton(
                                  size: 24,
                                  onPressed: () {
                                    if (widget.onRemove != null)
                                      widget.onRemove();
                                  },
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                  )),
                            ),
                        ],
                      ),
                    ],
                  ),
                ))),
      ],
    );
  }
}
