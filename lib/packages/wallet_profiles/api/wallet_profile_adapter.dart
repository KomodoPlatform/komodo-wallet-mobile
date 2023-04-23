import 'package:hive/hive.dart';
import 'package:komodo_dex/packages/wallet_profiles/models/wallet_profile.dart';

class WalletProfileAdapter extends TypeAdapter<WalletProfile> {
  @override
  final int typeId = 0;

  @override
  WalletProfile read(BinaryReader reader) {
    return WalletProfile(
      id: reader.readString(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, WalletProfile obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
  }
}
