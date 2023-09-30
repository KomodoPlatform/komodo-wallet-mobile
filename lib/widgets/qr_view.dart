import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScan extends StatefulWidget {
  const QRScan({Key key}) : super(key: key);

  @override
  State<QRScan> createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  bool gotQR = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).qrCodeScanner)),
      body: MobileScanner(
          allowDuplicates: false,
          controller: MobileScannerController(formats: [BarcodeFormat.qrCode]),
          onDetect: (barcode, args) async {
            if (gotQR) return;
            if (barcode.rawValue == null) {
              debugPrint('Failed to scan Barcode');
            } else {
              gotQR = true;
              final String code = barcode.rawValue;
              if (code != null) {
                debugPrint('Barcode found! $code');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context).foundQrCode)),
                );
                await Future.delayed(Duration(seconds: 1));

                Navigator.of(context).pop<String>(code);
              }
            }
          }),
    );
  }
}
