import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:komodo_dex/widgets/title_coin.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CoinDetail extends StatefulWidget {
  CoinBalance coinBalance;

  CoinDetail(this.coinBalance);

  @override
  _CoinDetailState createState() => _CoinDetailState();
}

class _CoinDetailState extends State<CoinDetail> {
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            PhotoHero(
              url:
                  "https://raw.githubusercontent.com/jl777/coins/master/icons/${widget.coinBalance.balance.coin.toLowerCase()}.png",
              radius: 16,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
                widget.coinBalance.coin.name.toUpperCase()),
          ],
        ),
        centerTitle: false,
        backgroundColor: Color(int.parse(widget.coinBalance.coin.colorCoin)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.coinBalance.coin.name),
          Text(widget.coinBalance.balance.address),
          QrImage(
            foregroundColor: Theme.of(context).textSelectionColor,
            data: widget.coinBalance.balance.address,
            size: 200.0,
          ),
          Text(widget.coinBalance.balance.balance.toString()),

        ],
      ),
    );
  }

  /// Open a activity for scan QRCode example usage:
  /// MaterialButton(onPressed: scan, child: new Text("SEND"))
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
