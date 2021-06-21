import 'package:komodo_dex/model/error_string.dart';

class BestOrder {}

class BestOrders {
  BestOrders({this.result, this.error});

  Map<String, List<BestOrder>> result;
  ErrorString error;
}
