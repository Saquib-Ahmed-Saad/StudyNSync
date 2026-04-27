import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await saveCurrentToken();

    _messaging.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });
  }

  Future<String?> saveCurrentToken() async {
    try {
      final token = await _messaging.getToken();

      if (token != null) {
        await _saveToken(token);
      }

      return token;
    } catch (_) {
      return null;
    }
  }

  Stream<RemoteMessage> get foregroundMessages {
    return FirebaseMessaging.onMessage;
  }

  Future<void> _saveToken(String token) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('fcmTokens').doc(token).set({
      'token': token,
      'platform': 'flutter',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}