part of 'wallet_address.dart';

class WalletAddressAdapter extends TypeAdapter<WalletAddress> {
  @override
  final typeId = 0;

  @override
  WalletAddress read(BinaryReader reader) {
    return WalletAddress(
      walletId: reader.read(),
      address: reader.read(),
      ticker: reader.read(),
      availableBalance: reader.read(),
      accountId: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, WalletAddress obj) {
    writer.write(obj.walletId);
    writer.write(obj.address);
    writer.write(obj.ticker);
    writer.write(obj.availableBalance);
    writer.write(obj.accountId);
  }
}
