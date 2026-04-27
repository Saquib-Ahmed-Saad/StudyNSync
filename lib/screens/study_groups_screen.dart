import 'package:flutter/material.dart';
import '../theme/study_n_sync_theme.dart';

class StudyGroupsScreen extends StatelessWidget {
  const StudyGroupsScreen({super.key});

  static const String routeName = '/study-groups';

  static const List<_StudyGroup> _groups = [
    _StudyGroup(
      name: 'Runes of Algorithms',
      course: 'CS301 - Algorithms',
      members: 5,
    ),
    _StudyGroup(
      name: 'Arcane Calculus Circle',
      course: 'MTH201 - Calculus II',
      members: 8,
    ),
    _StudyGroup(
      name: 'Archives of Databases',
      course: 'CS255 - Database Systems',
      members: 6,
    ),
    _StudyGroup(
      name: 'Scholars of Mechanics',
      course: 'PHY102 - Mechanics',
      members: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mage Circles')),
      body: ListView(
        padding: StudyNSyncSpacing.pagePadding,
        children: [
          const Text(
            'Mage Circles',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Join a focused study circle for your current course goals.',
            style: TextStyle(color: StudyNSyncColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Create Circle UI coming soon.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text('Create Circle'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Join Circle flow coming soon.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Join Circle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._groups.map(
            (group) => _StudyGroupCard(group: group),
          ),
        ],
      ),
    );
  }
}

class _StudyGroupCard extends StatelessWidget {
  const _StudyGroupCard({required this.group});

  final _StudyGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: StudyNSyncColors.parchment,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyNSyncColors.mutedGold),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: StudyNSyncColors.icyBlue.withValues(alpha: 0.2),
          child: const Icon(Icons.groups_rounded, color: StudyNSyncColors.deepNavy),
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: StudyNSyncColors.onParchment,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${group.course}\nMembers: ${group.members}',
            style: TextStyle(
              color: StudyNSyncColors.onParchment.withValues(alpha: 0.88),
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: StudyNSyncColors.deepNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: StudyNSyncColors.mutedGold.withValues(alpha: 0.7),
            ),
          ),
          child: const Text(
            'Open',
            style: TextStyle(
              color: StudyNSyncColors.deepNavy,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _StudyGroup {
  const _StudyGroup({
    required this.name,
    required this.course,
    required this.members,
  });

  final String name;
  final String course;
  final int members;
}
