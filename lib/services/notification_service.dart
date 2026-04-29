import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('BACKGROUND MESSAGE ID: ${message.messageId}');
  debugPrint('BACKGROUND MESSAGE TITLE: ${message.notification?.title}');
  debugPrint('BACKGROUND MESSAGE BODY: ${message.notification?.body}');
}

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    await saveCurrentToken();

    _messaging.onTokenRefresh.listen((token) async {
      debugPrint('FCM TOKEN REFRESHED: $token');
      await _saveToken(token);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FOREGROUND MESSAGE ID: ${message.messageId}');
      debugPrint('FOREGROUND MESSAGE TITLE: ${message.notification?.title}');
      debugPrint('FOREGROUND MESSAGE BODY: ${message.notification?.body}');
      debugPrint('FOREGROUND MESSAGE DATA: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('MESSAGE OPENED APP ID: ${message.messageId}');
      debugPrint('MESSAGE OPENED APP DATA: ${message.data}');
    });

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('APP OPENED FROM TERMINATED MESSAGE ID: ${initialMessage.messageId}');
      debugPrint('APP OPENED FROM TERMINATED MESSAGE DATA: ${initialMessage.data}');
    }
  }

  Future<String?> saveCurrentToken() async {
    try {
      final token = await _messaging.getToken();

      debugPrint('FCM TOKEN: $token');

      if (token != null) {
        await _saveToken(token);
      }

      return token;
    } catch (error) {
      debugPrint('FCM token error: $error');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      debugPrint('FCM token not saved because no user is signed in yet.');
      return;
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set(
      {
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    debugPrint('FCM token saved to Firestore for user: $uid');
  }
}