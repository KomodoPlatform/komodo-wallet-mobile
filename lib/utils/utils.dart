import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keccak/keccak.dart';

import '../localizations.dart';

copyToClipBoard(BuildContext context, String str) {
  Scaffold.of(context).showSnackBar(new SnackBar(
    duration: Duration(milliseconds: 300),
    content: new Text(AppLocalizations.of(context).clipboard),
  ));
  Clipboard.setData(new ClipboardData(text: str));
}

isAddress(String address) {
  if (RegExp("!/^(0x)?[0-9a-f]{40}\$/i").hasMatch(address)) {
    return false;
  } else if (RegExp("/^(0x)?[0-9a-f]{40}\$/").hasMatch(address) ||
      RegExp("/^(0x)?[0-9A-F]{40}\$/").hasMatch(address)) {
    return true;
  } else {
    return isChecksumAddress(address);
  }
}

isChecksumAddress(String address) {
  // Check each case
  address = address.replaceFirst("0x", "");
  var inputData = Uint8List.fromList(address.toLowerCase().codeUnits);
  var addressHash = keccak(inputData);
  var output = hex.encode(addressHash);
  for (var i = 0; i < 40; i++) {
    // the nth letter should be uppercase if the nth digit of casemap is 1
    // int.parse(addressHash[i].toString(), radix: 16)
    if ((int.parse(output[i].toString(), radix: 16) > 7 &&
            address[i].toUpperCase() != address[i]) ||
        (int.parse(output[i].toString(), radix: 16) <= 7 &&
            address[i].toLowerCase() != address[i])) {
      return false;
    }
  }
  return true;
}
