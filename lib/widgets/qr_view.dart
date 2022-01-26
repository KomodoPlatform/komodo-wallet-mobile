import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AppQRView extends StatefulWidget {
  const AppQRView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppQRViewState();
}

class _AppQRViewState extends State<AppQRView> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData == null || scanData.format != BarcodeFormat.qrcode) return;
      controller.stopCamera();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Found Qr Code')),
      );
      await Future.delayed(Duration(seconds: 3));

      Navigator.of(context).pop<Barcode>(scanData);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
