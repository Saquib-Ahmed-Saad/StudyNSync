import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/study_group.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';
import 'timer_screen.dart';

class StudyGroupsScreen extends StatelessWidget {
  const StudyGroupsScreen({super.key});

  static const String routeName = '/study-groups';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sign in first to view study groups.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(
          context,
          firestoreService,
          user.uid,
        ),
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Create Group'),
      ),
      body: StreamBuilder<List<StudyGroup>>(
        stream: firestoreService.watchGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Group error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!;

          if (groups.isEmpty) {
            return const Center(
              child: Text('No groups yet. Create the first study group.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Available Study Groups',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Join a group to chat and use the shared timer.'),
              const SizedBox(height: 16),
              ...groups.map(
                (group) => _GroupCard(
                  group: group,
                  currentUid: user.uid,
                  onJoin: () async {
                    await firestoreService.joinGroup(
                      groupId: group.id,
                      uid: user.uid,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined ${group.name}.')),
                    );
                  },
                  onOpenChat: () {
                    Navigator.pushNamed(
                      context,
                      ChatScreen.routeName,
                      arguments: {
                        'groupId': group.id,
                        'groupName': group.name,
                      },
                    );
                  },
                  onOpenTimer: () {
                    Navigator.pushNamed(
                      context,
                      TimerScreen.routeName,
                      arguments: {
                        'groupId': group.id,
                        'groupName': group.name,
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateGroupDialog(
    BuildContext context,
    FirestoreService firestoreService,
    String uid,
  ) async {
    final nameController = TextEditingController();
    final courseController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Study Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  hintText: 'CSC 4360 Project Group',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: 'Course code',
                  hintText: 'CSC4360',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final course = courseController.text.trim();

                if (name.isEmpty || course.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group name and course code are required.'),
                    ),
                  );
                  return;
                }

                await firestoreService.createGroup(
                  ownerId: uid,
                  name: name,
                  courseCode: course,
                );

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Study group created.')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    courseController.dispose();
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.currentUid,
    required this.onJoin,
    required this.onOpenChat,
    required this.onOpenTimer,
  });

  final StudyGroup group;
  final String currentUid;
  final Future<void> Function() onJoin;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenTimer;

  @override
  Widget build(BuildContext context) {
    final isMember = group.memberIds.contains(currentUid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${group.courseCode} • ${group.memberIds.length} member(s)'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: isMember ? null : onJoin,
                  icon: const Icon(Icons.group_add_rounded),
                  label: Text(isMember ? 'Joined' : 'Join'),
                ),
                OutlinedButton.icon(
                  onPressed: isMember ? onOpenChat : null,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                ),
                OutlinedButton.icon(
                  onPressed: isMember ? onOpenTimer : null,
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Timer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}