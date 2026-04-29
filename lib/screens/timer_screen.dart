import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/pomodoro_state.dart';
import '../models/study_group.dart';
import '../services/firestore_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  static const String routeName = '/timer';

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String? _groupId;
  String _groupName = 'Shared Timer';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _groupId = args['groupId'] as String?;
      _groupName = args['groupName'] as String? ?? 'Shared Timer';
    }
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in first to use the shared timer.')),
      );
    }

    if (_groupId != null && _groupId!.isNotEmpty) {
      return _TimerBody(
        groupId: _groupId!,
        groupName: _groupName,
        firestoreService: _firestoreService,
        currentUid: user.uid,
        formatSeconds: _formatSeconds,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shared Timer')),
      body: StreamBuilder<List<StudyGroup>>(
        stream: _firestoreService.watchGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Timer error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final joinedGroups = snapshot.data!
              .where((group) => group.memberIds.contains(user.uid))
              .toList();

          if (joinedGroups.isEmpty) {
            return const Center(
              child: Text('Join or create a study group before using the timer.'),
            );
          }

          final group = joinedGroups.first;

          return _TimerBody(
            groupId: group.id,
            groupName: group.name,
            firestoreService: _firestoreService,
            currentUid: user.uid,
            formatSeconds: _formatSeconds,
          );
        },
      ),
    );
  }
}

class _TimerBody extends StatelessWidget {
  const _TimerBody({
    required this.groupId,
    required this.groupName,
    required this.firestoreService,
    required this.currentUid,
    required this.formatSeconds,
  });

  final String groupId;
  final String groupName;
  final FirestoreService firestoreService;
  final String currentUid;
  final String Function(int seconds) formatSeconds;

  Future<void> _setGoal(BuildContext context, PomodoroState state) async {
    final controller = TextEditingController(text: state.sessionGoal);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Set Session Goal'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Goal',
              hintText: 'Finish Firebase testing evidence',
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = state.copyWith(
                  sessionGoal: controller.text.trim(),
                  controlledBy: currentUid,
                  updatedAt: DateTime.now(),
                );

                await firestoreService.setPomodoroState(groupId, updated);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
              },
              child: const Text('Save Goal'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName Timer'),
      ),
      body: StreamBuilder<PomodoroState>(
        stream: firestoreService.watchPomodoroState(groupId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Timer error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        formatSeconds(state.remainingSeconds),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mode: ${state.mode.name} • Status: ${state.runState.name}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.sessionGoal.isEmpty
                            ? 'Goal: No session goal set'
                            : 'Goal: ${state.sessionGoal}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed cycles: ${state.completedCycles}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              firestoreService.startPomodoro(
                                groupId,
                                currentUid,
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              firestoreService.pausePomodoro(
                                groupId,
                                currentUid,
                                state.remainingSeconds,
                              );
                            },
                            icon: const Icon(Icons.pause_rounded),
                            label: const Text('Pause'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              firestoreService.resetPomodoro(
                                groupId,
                                currentUid,
                              );
                            },
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Reset'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _setGoal(context, state),
                            icon: const Icon(Icons.flag_outlined),
                            label: const Text('Set Goal'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Timer state and goals are synchronized through Firestore.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}