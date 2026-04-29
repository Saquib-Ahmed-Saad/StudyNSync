import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/study_plan_item.dart';
import '../models/study_task.dart';
import '../services/firestore_service.dart';
import '../theme/study_n_sync_theme.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  static const String routeName = '/study-planner';

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();

  DateTime? _selectedDeadline;
  double _selectedEffortHours = 2;
  int _selectedCourseWeight = 5;
  StudyTask? _editingTask;
  bool _saving = false;
  bool _generating = false;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
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

  Future<void> _saveTask(String uid) async {
    final title = _taskTitleController.text.trim();
    final courseCode = _courseCodeController.text.trim();

    if (title.isEmpty || courseCode.isEmpty || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter title, course code, deadline, effort, and weight.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = DateTime.now();

      final task = StudyTask(
        id: _editingTask?.id ?? '',
        userId: uid,
        title: title,
        courseCode: courseCode,
        deadline: _selectedDeadline!,
        estimatedHours: _selectedEffortHours,
        courseWeight: _selectedCourseWeight,
        priorityScore: _editingTask?.priorityScore ?? 0,
        status: _editingTask?.status ?? TaskStatus.todo,
        createdAt: _editingTask?.createdAt ?? now,
        updatedAt: now,
      );

      if (_editingTask == null) {
        await _firestoreService.addTask(uid, task);
      } else {
        await _firestoreService.updateTask(uid, task);
      }

      _clearForm();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingTask == null ? 'Task saved.' : 'Task updated.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task save failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _generateWeeklyPlan(String uid) async {
    setState(() {
      _generating = true;
    });

    try {
      final plan = await _firestoreService.generateAndSaveWeeklyPlan(uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated ${plan.length} weekly study block(s).'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan generation failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _generating = false;
        });
      }
    }
  }

  void _editTask(StudyTask task) {
    setState(() {
      _editingTask = task;
      _taskTitleController.text = task.title;
      _courseCodeController.text = task.courseCode;
      _selectedDeadline = task.deadline;
      _selectedEffortHours = task.estimatedHours;
      _selectedCourseWeight = task.courseWeight;
    });
  }

  void _clearForm() {
    setState(() {
      _editingTask = null;
      _taskTitleController.clear();
      _courseCodeController.clear();
      _selectedDeadline = null;
      _selectedEffortHours = 2;
      _selectedCourseWeight = 5;
    });
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Select deadline';

    return '${date.month}/${date.day}/${date.year}';
  }

  String _timeLabel(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.month}/${date.day} $hour:$minute';
  }

  Color _priorityColor(int score) {
    if (score >= 80) return Colors.redAccent;
    if (score >= 55) return StudyNSyncColors.mutedGold;
    return StudyNSyncColors.icyBlue;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sign in first to use the study planner.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
      ),
      body: ListView(
        padding: StudyNSyncSpacing.pagePadding,
        children: [
          const Text(
            'Weekly Study-Plan Assistant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tasks are stored in Firestore and ranked by deadline, effort, and course weight.',
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
                  Text(
                    _editingTask == null ? 'Add New Task' : 'Edit Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
                  TextField(
                    controller: _courseCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Course code',
                      hintText: 'CSC4360',
                      prefixIcon: const Icon(Icons.school_rounded),
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
                  DropdownButtonFormField<double>(
                    initialValue: _selectedEffortHours,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 hour - Low Effort')),
                      DropdownMenuItem(value: 2, child: Text('2 hours - Medium Effort')),
                      DropdownMenuItem(value: 4, child: Text('4 hours - High Effort')),
                      DropdownMenuItem(value: 6, child: Text('6 hours - Major Effort')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedEffortHours = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Estimated effort',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCourseWeight,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1/10 - Small grade impact')),
                      DropdownMenuItem(value: 3, child: Text('3/10 - Light grade impact')),
                      DropdownMenuItem(value: 5, child: Text('5/10 - Medium grade impact')),
                      DropdownMenuItem(value: 7, child: Text('7/10 - High grade impact')),
                      DropdownMenuItem(value: 10, child: Text('10/10 - Major grade impact')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : () => _saveTask(user.uid),
                          icon: const Icon(Icons.save_rounded),
                          label: Text(
                            _editingTask == null ? 'Save Task' : 'Update Task',
                          ),
                        ),
                      ),
                      if (_editingTask != null) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _clearForm,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Firestore Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _generating ? null : () => _generateWeeklyPlan(user.uid),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(_generating ? 'Generating...' : 'Generate Plan'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          StreamBuilder<List<StudyTask>>(
            stream: _firestoreService.watchTasks(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Task error: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data!;

              if (tasks.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No tasks added yet. Add a task above.'),
                  ),
                );
              }

              return Column(
                children: tasks.map((task) {
                  final priorityColor = _priorityColor(task.priorityScore);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: priorityColor.withValues(alpha: 0.16),
                        child: Icon(
                          task.status == TaskStatus.done
                              ? Icons.check_rounded
                              : Icons.auto_stories_rounded,
                          color: priorityColor,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${task.courseCode} • Due ${_dateLabel(task.deadline)} • '
                        '${task.estimatedHours.toStringAsFixed(1)} hr • Weight ${task.courseWeight}/10 • '
                        'Priority ${task.priorityScore}',
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Mark done/undone',
                            onPressed: () async {
                              final nextStatus = task.status == TaskStatus.done
                                  ? TaskStatus.todo
                                  : TaskStatus.done;

                              await _firestoreService.updateTask(
                                user.uid,
                                task.copyWith(status: nextStatus),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline),
                          ),
                          IconButton(
                            tooltip: 'Edit task',
                            onPressed: () => _editTask(task),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete task',
                            onPressed: () async {
                              await _firestoreService.deleteTask(user.uid, task.id);
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Generated Weekly Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Recommendations are editable by changing the source task and regenerating the plan.',
            style: TextStyle(color: StudyNSyncColors.textSecondary),
          ),
          const SizedBox(height: 10),

          StreamBuilder<List<StudyPlanItem>>(
            stream: _firestoreService.watchWeeklyPlan(user.uid, DateTime.now()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Plan error: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final planItems = snapshot.data!;

              if (planItems.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No weekly plan generated yet. Tap Generate Plan.'),
                  ),
                );
              }

              return Column(
                children: planItems.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.hasConflict
                            ? Colors.redAccent.withValues(alpha: 0.16)
                            : Colors.green.withValues(alpha: 0.16),
                        child: Icon(
                          item.hasConflict
                              ? Icons.warning_amber_rounded
                              : Icons.event_available_rounded,
                          color: item.hasConflict ? Colors.redAccent : Colors.green,
                        ),
                      ),
                      title: Text(
                        '${item.courseCode}: ${item.taskTitle}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_timeLabel(item.startTime)} → ${_timeLabel(item.endTime)}',
                            ),
                            const SizedBox(height: 4),
                            Text(item.recommendationReason),
                            if (item.hasConflict) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Suggestion: ${item.adjustmentSuggestion}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}