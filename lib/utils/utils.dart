import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keccak/keccak.dart';

import '../localizations.dart';

void copyToClipBoard(BuildContext context, String str) {
  Scaffold.of(context).showSnackBar( SnackBar(
    duration: const Duration(milliseconds: 300),
    content:  Text(AppLocalizations.of(context).clipboard),
  ));
  Clipboard.setData( ClipboardData(text: str));
}

bool isAddress(String address) {
  if (RegExp('!/^(0x)?[0-9a-f]{40}\$/i').hasMatch(address)) {
    return false;
  } else if (RegExp('/^(0x)?[0-9a-f]{40}\$/').hasMatch(address) ||
      RegExp('/^(0x)?[0-9A-F]{40}\$/').hasMatch(address)) {
    return true;
  } else {
    return isChecksumAddress(address);
  }
}

bool isChecksumAddress(String address) {
  // Check each case
  address = address.replaceFirst('0x', '');
  final Uint8List inputData = Uint8List.fromList(address.toLowerCase().codeUnits);
  final Uint8List addressHash = keccak(inputData);
  final String output = hex.encode(addressHash);
  for (int i = 0; i < 40; i++) {
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

String replaceAllTrainlingZero(String data) {
  for (int i = 0; i < 8; i++) {
    data = data.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
  return data;
}

String replaceAllTrainlingZeroERC(String data) {
  for (int i = 0; i < 16; i++) {
    data = data.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
  return data;
}
