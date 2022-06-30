import 'package:flutter/material.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/services/db/database.dart';

class MakerOrderNote extends StatefulWidget {
  const MakerOrderNote(this.order);

  final Order order;

  @override
  _MakerOrderNoteState createState() => _MakerOrderNoteState();
}

class _MakerOrderNoteState extends State<MakerOrderNote> {
  String noteId;
  String noteText;
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
        noteTextController.text = noteText;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
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
              : InkWell(
                  onTap: noteText != null && noteText.isNotEmpty
                      ? () {
                          setState(() {
                            isEdit = true;
                          });

                          noteTextController.text =
                              noteTextController.text.trim();
                          noteText = noteTextController.text;
                          focusNode.requestFocus();
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      (noteText == null || noteText.isEmpty)
                          ? AppLocalizations.of(context).notePlaceholder
                          : noteText,
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                ),
        ),
        // todo(MRC): Switch to IconButton
        InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(isEdit ? Icons.check : Icons.edit, size: 18)),
          onTap: () {
            setState(
              () {
                if (isEdit) {
                  noteTextController.text = noteTextController.text.trim();
                  noteText = noteTextController.text;
                  noteText.isNotEmpty
                      ? Db.saveNote(noteId, noteText)
                      : Db.deleteNote(noteId);

                  setState(() {
                    isExpanded = false;
                  });
                }
                if (!isEdit) {
                  focusNode.requestFocus();
                }
                setState(() {
                  isEdit = !isEdit;
                });
              },
            );
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    noteTextController.dispose();
    super.dispose();
  }
}
