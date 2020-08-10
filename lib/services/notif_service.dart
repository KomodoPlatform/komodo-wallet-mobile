import 'package:flutter/services.dart';
import 'package:komodo_dex/services/mm_service.dart';

NotifService notifService = NotifService();

class NotifService {
  MethodChannel chanell = MMService.nativeC;

  Future<void> show(NotifObj notif) async {
    await chanell.invokeMethod<void>('show_notification', <String, dynamic>{
      'title': notif.title,
      'text': notif.text,
    });
  }
}

class NotifObj {
  NotifObj({
    this.title,
    this.text,
  });

  String title;
  String text;
}
