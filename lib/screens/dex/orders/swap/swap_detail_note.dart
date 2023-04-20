import 'package:flutter/material.dart';

import '../../../../app_config/theme_data.dart';
import '../../../../localizations.dart';
import '../../../../services/db/database.dart';
import '../../../../utils/utils.dart';

class SwapDetailNote extends StatefulWidget {
  const SwapDetailNote(this.uuid);

  final String? uuid;
  @override
  State<SwapDetailNote> createState() => _SwapDetailNoteState();
}

class _SwapDetailNoteState extends State<SwapDetailNote> {
  String? noteText;
  bool isNoteEdit = false;
  bool isNoteExpanded = false;
  final noteTextController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Db.getNote(widget.uuid!).then((n) {
      setState(() {
        noteText = n;
        noteTextController.text = noteText!;
      });
    });
  }

  @override
  void dispose() {
    noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: isNoteEdit
                  ? null
                  : () {
                      setState(() {
                        isNoteEdit = true;
                      });

                      noteTextController.text = noteTextController.text.trim();
                      noteText = noteTextController.text;
                      focusNode.requestFocus();

                      if (noteText != null && noteText!.isNotEmpty) {
                        setState(() {
                          isNoteExpanded = !isNoteExpanded;
                        });
                      }
                    },
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 0, 8),
                  child: Row(
                    crossAxisAlignment: isNoteEdit
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                AppLocalizations.of(context)!.noteTitle + ':',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            isNoteEdit
                                ? Theme(
                                    data: Theme.of(context).copyWith(
                                      inputDecorationTheme:
                                          defaultUnderlineInputTheme(
                                              Theme.of(context).colorScheme),
                                    ),
                                    child: TextField(
                                      decoration:
                                          InputDecoration(isDense: true),
                                      controller: noteTextController,
                                      maxLength: 200,
                                      maxLines: 7,
                                      minLines: 1,
                                      focusNode: focusNode,
                                    ),
                                  )
                                : Text(
                                    (noteText == null || noteText!.isEmpty)
                                        ? AppLocalizations.of(context)!
                                            .notePlaceholder
                                        : noteText!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                    maxLines: isNoteExpanded ? null : 1,
                                    overflow: isNoteExpanded
                                        ? null
                                        : TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(isNoteEdit ? Icons.check : Icons.edit),
                        onPressed: () {
                          setState(
                            () {
                              if (isNoteEdit) {
                                noteText = noteTextController.text.trim();
                                noteTextController.text = noteText!;

                                noteText!.isNotEmpty
                                    ? Db.saveNote(widget.uuid!, noteText!)
                                    : Db.deleteNote(widget.uuid!);

                                setState(() {
                                  isNoteExpanded = false;
                                });
                              } else {
                                focusNode.requestFocus();
                              }

                              setState(() {
                                isNoteEdit = !isNoteEdit;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  )),
            ),
          ),
          if (noteText?.isNotEmpty ?? false)
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () => copyToClipBoard(context, noteText),
            ),
        ],
      ),
    );
  }
}
