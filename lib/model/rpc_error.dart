class RpcError {
  RpcError({
    this.type,
    this.message,
    this.data,
  });

  factory RpcError.fromJson(Map<String, dynamic> json) {
    RpcErrorType type;
    switch (json['error_type']) {
      case 'VolumeTooLow':
        type = RpcErrorType.VolumeTooLow;
        break;
      case 'NotSufficientBalance':
        type = RpcErrorType.NotSufficientBalance;
        break;
      case 'NotSufficientBaseCoinBalance':
        type = RpcErrorType.NotSufficientBaseCoinBalance;
        break;
      case 'NoSuchCoin':
        type = RpcErrorType.NoSuchCoin;
        break;
      case 'CoinIsWalletOnly':
        type = RpcErrorType.CoinIsWalletOnly;
        break;
      case 'BaseEqualRel':
        type = RpcErrorType.BaseEqualRel;
        break;
      case 'InvalidParam':
        type = RpcErrorType.InvalidParam;
        break;
      case 'PriceTooLow':
        type = RpcErrorType.PriceTooLow;
        break;
      case 'Transport':
        type = RpcErrorType.Transport;
        break;
      case 'InternalError':
        type = RpcErrorType.InternalError;
        break;
      default:
        type = RpcErrorType.unknown;
    }

    return RpcError(
      type: type,
      data: json['error_data'],
      message: json['error'],
    );
  }

  RpcErrorType type;
  String message;
  dynamic data;
}

enum RpcErrorType {
  connectionError,
  decodingError,
  mappingError,
  NotSufficientBalance,
  NotSufficientBaseCoinBalance,
  VolumeTooLow,
  NoSuchCoin,
  CoinIsWalletOnly,
  BaseEqualRel,
  InvalidParam,
  PriceTooLow,
  Transport,
  InternalError,
  unknown,
}
