import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/import-export/export_notes.dart';
import 'package:komodo_dex/screens/import-export/import_notes.dart';

class ImportExportScreen extends StatefulWidget {
  @override
  _ImportExportScreenState createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: const Text('Import Notes'),
              onPressed: () {
                Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            ImportNotesScreen()));
              },
            ),
            RaisedButton(
              child: const Text('Export Notes'),
              onPressed: () {
                Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            ExportNotesScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
