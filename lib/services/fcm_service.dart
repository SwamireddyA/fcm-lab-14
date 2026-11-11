import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

typedef FcmEventCallback = void Function(String handler, RemoteMessage message);

/// Owns every FCM listener so widgets stay UI-only.
/// - onMessage: receipt while the app is in the foreground (T1, T4)
/// - onMessageOpenedApp: user tapped a notification while app was backgrounded (T2)
/// - getInitialMessage: user tapped a notification that cold-started the app (T3)
/// onBackgroundMessage is registered separately in main.dart (top-level isolate).
class FCMService {
  FCMService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final List<StreamSubscription<dynamic>> _subs = [];
  bool _initialized = false;

  Future<void> initialize({
    required FcmEventCallback onEvent,
    void Function(String token)? onToken,
    void Function(String status)? onPermission,
  }) async {
    if (_initialized) return; // guard against duplicate listeners
    _initialized = true;

    final settings = await _messaging.requestPermission();
    onPermission?.call(settings.authorizationStatus.name);

    final token = await _messaging.getToken();
    debugPrint('[FCM] token: $token');
    if (token != null) onToken?.call(token);
    _subs.add(_messaging.onTokenRefresh.listen((t) => onToken?.call(t)));

    _subs.add(FirebaseMessaging.onMessage.listen((m) {
      debugPrint('[FCM] onMessage id=${m.messageId} data=${m.data}');
      onEvent('onMessage', m);
    }));
    _subs.add(FirebaseMessaging.onMessageOpenedApp.listen((m) {
      debugPrint('[FCM] onMessageOpenedApp id=${m.messageId} data=${m.data}');
      onEvent('onMessageOpenedApp', m);
    }));

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] getInitialMessage id=${initial.messageId} data=${initial.data}');
      onEvent('getInitialMessage', initial);
    }
  }

  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _initialized = false;
  }
}
