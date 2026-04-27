import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../models/study_task.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  final TextEditingController _nameController = TextEditingController(
    text: 'Brendon Huang',
  );

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );

  String _log = 'Backend test screen ready.';
  bool _busy = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runSafely(Future<void> Function() action) async {
    setState(() => _busy = true);

    try {
      await action();
    } catch (error) {
      setState(() => _log = 'ERROR: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _signUp() async {
    await _runSafely(() async {
      await _authService.signUpWithCampusEmail(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );

      await _notificationService.saveCurrentToken();

      setState(() {
        _log = 'Signed up and created Firestore user profile.';
      });
    });
  }

  Future<void> _signIn() async {
    await _runSafely(() async {
      await _authService.signInWithCampusEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _notificationService.saveCurrentToken();

      setState(() {
        _log = 'Signed in and saved FCM token if available.';
      });
    });
  }

  Future<void> _seedDemoData() async {
    await _runSafely(() async {
      final user = _user;

      if (user == null) {
        setState(() {
          _log = 'Sign in first before seeding demo data.';
        });
        return;
      }

      await _firestoreService.seedDemoRooms();

      final now = DateTime.now();

      await _firestoreService.addTask(
        user.uid,
        StudyTask(
          id: '',
          userId: user.uid,
          title: 'Finish Mobile App Project 2 backend testing',
          courseCode: 'CSC4360',
          deadline: now.add(const Duration(days: 2)),
          estimatedHours: 4,
          courseWeight: 9,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final groupId = await _firestoreService.createGroup(
        ownerId: user.uid,
        name: 'CSC 4360 Study Group',
        courseCode: 'CSC4360',
      );

      await _firestoreService.sendMessage(
        groupId: groupId,
        senderId: user.uid,
        senderName: user.displayName ?? 'Brendon',
        text: 'Backend chat test message from Firestore.',
      );

      await _firestoreService.scheduleSession(
        StudySession(
          id: '',
          groupId: groupId,
          title: 'Project 2 Backend Review',
          createdBy: user.uid,
          participantIds: [user.uid],
          startTime: now.add(const Duration(days: 1, hours: 1)),
          endTime: now.add(const Duration(days: 1, hours: 2)),
          location: 'Library 101',
          createdAt: now,
        ),
      );

      await _firestoreService.generateAndSaveWeeklyPlan(user.uid);

      await _notificationService.saveCurrentToken();

      setState(() {
        _log =
            'Seeded rooms, task, group, chat message, session, weekly plan, timer state, and FCM token.';
      });
    });
  }

  Future<void> _signOut() async {
    await _runSafely(() async {
      await _authService.signOut();

      setState(() {
        _log = 'Signed out.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brendon Backend Test'),
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: _busy ? null : _signOut,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            user == null ? 'Not signed in' : 'Signed in as: ${user.email}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Campus email',
              hintText: 'brendon@student.gsu.edu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : _signUp,
                icon: const Icon(Icons.person_add),
                label: const Text('Sign Up'),
              ),
              ElevatedButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
              ElevatedButton.icon(
                onPressed: _busy ? null : _seedDemoData,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Seed/Verify Backend Demo Data'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Text(_log),
          const Divider(height: 32),
          const Text('What this proves:'),
          const Text('• Auth signup/signin creates a Firebase user and profile document'),
          const Text('• Firestore creates tasks, groups, messages, sessions, rooms, and plans'),
          const Text('• Room availability uses transactions'),
          const Text('• Shared timer state is stored under the group'),
          const Text('• FCM token is saved under the signed-in user when available'),
        ],
      ),
    );
  }
}