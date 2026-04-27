import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const List<String> allowedCampusDomains = <String>[
    'student.gsu.edu',
    'gsu.edu',
  ];

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  static bool isCampusEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return allowedCampusDomains.any((domain) => normalized.endsWith('@$domain'));
  }

  static String? validateEmail(String email) {
    final trimmed = email.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (trimmed.isEmpty) return 'Email is required.';
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address.';
    if (!isCampusEmail(trimmed)) {
      return 'Use a campus email ending in @student.gsu.edu or @gsu.edu.';
    }

    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  Future<AppUser> signUpWithCampusEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) throw ArgumentError(emailError);

    final passwordError = validatePassword(password);
    if (passwordError != null) throw ArgumentError(passwordError);

    if (displayName.trim().isEmpty) {
      throw ArgumentError('Display name is required.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-create-failed',
        message: 'Firebase did not return a user account.',
      );
    }

    await user.updateDisplayName(displayName.trim());

    final now = DateTime.now();

    final appUser = AppUser(
      uid: user.uid,
      email: user.email ?? email.trim().toLowerCase(),
      displayName: displayName.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

    return appUser;
  }

  Future<UserCredential> signInWithCampusEmail({
    required String email,
    required String password,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) throw ArgumentError(emailError);

    final passwordError = validatePassword(password);
    if (passwordError != null) throw ArgumentError(passwordError);

    return _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    final emailError = validateEmail(email);
    if (emailError != null) throw ArgumentError(emailError);

    await _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _requireUser();

    if (displayName.trim().isEmpty) {
      throw ArgumentError('Display name is required.');
    }

    await user.updateDisplayName(displayName.trim());

    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User _requireUser() {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'A signed-in user is required for this action.',
      );
    }

    return user;
  }
}