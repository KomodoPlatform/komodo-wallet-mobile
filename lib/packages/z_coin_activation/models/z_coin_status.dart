import 'package:flutter/foundation.dart';

enum ActivationTaskStatus { active, failed, inProgress, notFound }

class ZCoinStatus {
  ZCoinStatus({
    @required this.coin,
    @required this.status,
    this.message = '',
    this.progress = 0,
  }) : assert(progress >= 0 && progress <= 1);

  ZCoinStatus.fromTaskStatus(String coin, ActivationTaskStatus status)
      : this(
          coin: coin,
          status: status ?? ActivationTaskStatus.notFound,
        );

  ZCoinStatus.completed(String coin)
      : this(
          coin: coin,
          status: ActivationTaskStatus.active,
          message: 'Completed',
          progress: 1,
        );

  final String coin;
  final ActivationTaskStatus status;
  final String message;
  final double progress;

  bool get isActivated =>
      status == ActivationTaskStatus.active ||
      message.contains('is activated already');

  bool get isFailed => status == ActivationTaskStatus.failed && !isActivated;

  bool get isInProgress => status == ActivationTaskStatus.inProgress;

  bool get isCompleted => isActivated || isFailed;

  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'status': status.toString(),
      'message': message,
      'progress': progress,
    };
  }
}
