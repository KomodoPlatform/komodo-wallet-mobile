import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/import-export/export_notes.dart';
import 'package:komodo_dex/screens/import-export/import_addressbook.dart';
import 'package:komodo_dex/screens/import-export/import_notes.dart';
import 'package:komodo_dex/screens/import-export/export_addressbook.dart';

class ImportExportPage extends StatefulWidget {
  @override
  _ImportExportPageState createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
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
            RaisedButton(
              child: const Text('Import Addressbook'),
              onPressed: () {
                Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            ImportAddressbookScreen()));
              },
            ),
            RaisedButton(
              child: const Text('Export Addressbook'),
              onPressed: () {
                Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            ExportAddressbookScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
