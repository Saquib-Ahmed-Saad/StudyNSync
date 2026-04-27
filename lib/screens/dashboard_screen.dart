import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'study_groups_screen.dart';
import 'study_planner_screen.dart';
import 'study_room_finder_screen.dart';
import 'timer_screen.dart';
import '../theme/study_n_sync_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  static const int upcomingStudyQuests = 6;
  static const int activeMageCircles = 3;
  static const int focusRituals = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StudyNSync')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Welcome back, Student',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'A calm view of today\'s academic momentum.',
            style: TextStyle(color: StudyNSyncColors.textSecondary),
          ),
          const SizedBox(height: 18),
          const Text(
            'Great Hall',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const _HallStatCard(
            title: 'Upcoming Study Quests',
            value: '$upcomingStudyQuests',
            icon: Icons.auto_stories_rounded,
          ),
          const _HallStatCard(
            title: 'Active Mage Circles',
            value: '$activeMageCircles',
            icon: Icons.groups_rounded,
          ),
          const _HallStatCard(
            title: 'Focus Rituals',
            value: '$focusRituals',
            icon: Icons.hourglass_top_rounded,
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick Navigation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _NavCard(
            title: 'Study Planner',
            subtitle: 'Plan your tasks and deadlines',
            icon: Icons.edit_calendar_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyPlannerScreen()),
            ),
          ),
          _NavCard(
            title: 'Study Room Finder',
            subtitle: 'Locate available rooms to focus',
            icon: Icons.meeting_room_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyRoomFinderScreen()),
            ),
          ),
          _NavCard(
            title: 'Study Groups',
            subtitle: 'Connect and collaborate with peers',
            icon: Icons.group_work_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyGroupsScreen()),
            ),
          ),
          _NavCard(
            title: 'Chat',
            subtitle: 'Message your study partners',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
          _NavCard(
            title: 'Timer',
            subtitle: 'Track focused sessions',
            icon: Icons.timer_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimerScreen()),
            ),
          ),
          _NavCard(
            title: 'Profile',
            subtitle: 'Manage account and preferences',
            icon: Icons.person_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HallStatCard extends StatelessWidget {
  const _HallStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: StudyNSyncColors.parchment,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyNSyncColors.mutedGold),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          decoration: BoxDecoration(
            color: StudyNSyncColors.icyBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: StudyNSyncColors.deepNavy,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: StudyNSyncColors.onParchment,
          ),
        ),
        subtitle: Text(
          'Current total',
          style: TextStyle(
            color: StudyNSyncColors.onParchment.withValues(alpha: 0.72),
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: StudyNSyncColors.deepNavy,
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: StudyNSyncColors.icyBlue.withValues(alpha: 0.16),
          child: Icon(icon, color: StudyNSyncColors.icyBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
