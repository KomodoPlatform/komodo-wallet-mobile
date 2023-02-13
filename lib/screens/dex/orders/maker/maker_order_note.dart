import 'package:flutter/material.dart';
import '../../../../app_config/theme_data.dart';
import '../../../../localizations.dart';
import '../../../../model/order.dart';
import '../../../../services/db/database.dart';
import '../../../../utils/utils.dart';

class MakerOrderNote extends StatefulWidget {
  const MakerOrderNote(this.order);

  final Order order;

  @override
  _MakerOrderNoteState createState() => _MakerOrderNoteState();
}

class _MakerOrderNoteState extends State<MakerOrderNote> {
  String? noteId;
  String? noteText;
  final noteTextController = TextEditingController();
  bool isEdit = false;
  bool isExpanded = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    noteId = 'maker_${widget.order.uuid}';
    Db.getNote(noteId).then((n) {
      setState(() {
        noteText = n;
        noteTextController.text = noteText!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: isEdit
                ? null
                : () {
                    setState(() {
                      isEdit = true;
                    });

                    noteTextController.text = noteTextController.text.trim();
                    noteText = noteTextController.text;
                    focusNode.requestFocus();
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
            child: Row(
              children: [
                Expanded(
                  child: isEdit
                      ? Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: gefaultUnderlineInputTheme,
                          ),
                          child: TextField(
                            controller: noteTextController,
                            maxLength: 200,
                            minLines: 1,
                            maxLines: 8,
                            focusNode: focusNode,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            (noteText == null || noteText!.isEmpty)
                                ? AppLocalizations.of(context)!.notePlaceholder
                                : noteText!,
                            maxLines: isExpanded ? null : 1,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ),
                ),
                IconButton(
                  icon: Icon(isEdit ? Icons.check : Icons.edit, size: 18),
                  onPressed: () {
                    setState(
                      () {
                        if (isEdit) {
                          noteTextController.text =
                              noteTextController.text.trim();
                          noteText = noteTextController.text;
                          noteText!.isNotEmpty
                              ? Db.saveNote(noteId, noteText)
                              : Db.deleteNote(noteId);

                          setState(() {
                            isExpanded = false;
                          });
                        } else {
                          focusNode.requestFocus();
                        }

                        setState(() {
                          isEdit = !isEdit;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (noteText?.isNotEmpty ?? false)
          IconButton(
            icon: Icon(Icons.copy, size: 18),
            onPressed: () {
              copyToClipBoard(context, noteText);
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    noteTextController.dispose();
    super.dispose();
  }
}
