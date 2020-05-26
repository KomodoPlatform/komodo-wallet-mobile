import 'package:flutter/material.dart';

class BuildActivityItemDetailsButton extends StatelessWidget {
  const BuildActivityItemDetailsButton({
    @required this.iconData,
    @required this.title,
    @required this.onTap,
    this.vertical = false,
  });

  final IconData iconData;
  final String title;
  final Function onTap;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _content = [
      Icon(iconData,
          size: 20, color: Theme.of(context).textTheme.caption.color),
      SizedBox(
        width: vertical ? 0 : 4,
        height: vertical ? 4 : 0,
      ),
      Text(title,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.caption.color,
          )),
    ];

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: vertical
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _content,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _content,
                ),
        ),
      ),
    );
  }
}
