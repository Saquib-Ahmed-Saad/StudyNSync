import 'package:flutter/material.dart';
import '../theme/study_n_sync_theme.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  static const String routeName = '/timer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Ritual')),
      body: Center(
        child: SingleChildScrollView(
          padding: StudyNSyncSpacing.pagePadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    StudyNSyncColors.midnightBlue,
                    StudyNSyncColors.deepNavy,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: StudyNSyncColors.mutedGold, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Focus Ritual',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Calm, focused work guided by intentional study blocks.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StudyNSyncColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: StudyNSyncColors.parchment.withValues(alpha: 0.96),
                        border: Border.all(color: StudyNSyncColors.mutedGold),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: StudyNSyncColors.deepNavy,
                            size: 34,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '25:00',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: StudyNSyncColors.deepNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: StudyNSyncColors.charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: StudyNSyncColors.icyBlue.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 18,
                            color: StudyNSyncColors.icyBlue,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Session goal: Summarize chapter 5 and solve 3 practice problems.',
                              style: TextStyle(
                                fontSize: 13,
                                color: StudyNSyncColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Start pressed (UI demo).'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pause pressed (UI demo).'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.pause_rounded),
                            label: const Text('Pause'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reset pressed (UI demo).'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
