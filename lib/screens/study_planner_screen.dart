import 'package:flutter/material.dart';
import '../theme/study_n_sync_theme.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  static const String routeName = '/study-planner';

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final TextEditingController _taskTitleController = TextEditingController();

  DateTime? _selectedDeadline;
  String _selectedEffort = 'Medium';
  String _selectedCourseWeight = '20%';

  final List<_TaskItem> _tasks = [
    _TaskItem(
      title: 'Revise Chapter 4 Notes',
      deadline: DateTime(2026, 5, 2),
      effort: 'Medium',
      weight: '20%',
    ),
    _TaskItem(
      title: 'Prepare Presentation Slides',
      deadline: DateTime(2026, 5, 5),
      effort: 'High',
      weight: '30%',
    ),
    _TaskItem(
      title: 'Complete Quiz Practice',
      deadline: DateTime(2026, 5, 7),
      effort: 'Low',
      weight: '10%',
    ),
  ];

  @override
  void dispose() {
    _taskTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 3),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  void _addTask() {
    final String title = _taskTitleController.text.trim();
    if (title.isEmpty || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter task title and select deadline.'),
        ),
      );
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        _TaskItem(
          title: title,
          deadline: _selectedDeadline!,
          effort: _selectedEffort,
          weight: _selectedCourseWeight,
        ),
      );
      _taskTitleController.clear();
      _selectedDeadline = null;
      _selectedEffort = 'Medium';
      _selectedCourseWeight = '20%';
    });
  }

  String _dateLabel(DateTime? date) {
    if (date == null) {
      return 'Select deadline';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _effortColor(String effort) {
    switch (effort) {
      case 'High':
        return const Color(0xFFC27171);
      case 'Medium':
        return StudyNSyncColors.mutedGold;
      default:
        return StudyNSyncColors.icyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quest Board')),
      body: ListView(
        padding: StudyNSyncSpacing.pagePadding,
        children: [
          const Text(
            'Study Ledger',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Record your tasks with purpose and clear milestones.',
            style: TextStyle(color: StudyNSyncColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: StudyNSyncSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Quest',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _taskTitleController,
                    decoration: InputDecoration(
                      labelText: 'Task title',
                      prefixIcon: const Icon(Icons.task_alt_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDeadline,
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      color: StudyNSyncColors.icyBlue,
                    ),
                    label: Text(_dateLabel(_selectedDeadline)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEffort,
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('Low Effort')),
                      DropdownMenuItem(
                        value: 'Medium',
                        child: Text('Medium Effort'),
                      ),
                      DropdownMenuItem(value: 'High', child: Text('High Effort')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedEffort = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Effort',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourseWeight,
                    items: const [
                      DropdownMenuItem(value: '10%', child: Text('10%')),
                      DropdownMenuItem(value: '20%', child: Text('20%')),
                      DropdownMenuItem(value: '30%', child: Text('30%')),
                      DropdownMenuItem(value: '40%', child: Text('40%')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCourseWeight = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Course weight',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Task to Ledger'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Active Quests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ..._tasks.map(
            (task) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: StudyNSyncColors.parchment,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: StudyNSyncColors.mutedGold,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: StudyNSyncColors.deepNavy.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: StudyNSyncColors.deepNavy,
                  ),
                ),
                title: Text(
                  task.title,
                  style: const TextStyle(
                    color: StudyNSyncColors.onParchment,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due: ${_dateLabel(task.deadline)}',
                        style: const TextStyle(color: StudyNSyncColors.onParchment),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          _InfoChip(
                            label: 'Effort: ${task.effort}',
                            color: _effortColor(task.effort),
                          ),
                          _InfoChip(
                            label: 'Weight: ${task.weight}',
                            color: StudyNSyncColors.deepNavy,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem {
  const _TaskItem({
    required this.title,
    required this.deadline,
    required this.effort,
    required this.weight,
  });

  final String title;
  final DateTime deadline;
  final String effort;
  final String weight;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
