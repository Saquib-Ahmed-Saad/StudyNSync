import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/group_message.dart';
import '../models/pomodoro_state.dart';
import '../models/study_group.dart';
import '../models/study_plan_item.dart';
import '../models/study_room.dart';
import '../models/study_session.dart';
import '../models/study_task.dart';
import 'study_planner_service.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final StudyPlannerService _planner = StudyPlannerService();

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> get _rooms {
    return _firestore.collection('rooms');
  }

  CollectionReference<Map<String, dynamic>> get _groups {
    return _firestore.collection('groups');
  }

  CollectionReference<Map<String, dynamic>> get _sessions {
    return _firestore.collection('sessions');
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return AppUser.fromMap(doc.id, data);
    });
  }

  Future<void> updateUserCourses(String uid, List<String> courseIds) {
    return _users.doc(uid).update({
      'courseIds': courseIds.map((course) => course.trim().toUpperCase()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) {
    return _users.doc(uid).collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _plansRef(String uid) {
    return _users.doc(uid).collection('weeklyPlans');
  }

  Stream<List<StudyTask>> watchTasks(String uid) {
    return _tasksRef(uid).orderBy('deadline').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StudyTask.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<String> addTask(String uid, StudyTask task) async {
    _validateTask(task);

    final now = DateTime.now();

    final scoredTask = task.copyWith(
      userId: uid,
      priorityScore: _planner.calculatePriorityScore(task, now: now),
      createdAt: now,
      updatedAt: now,
    );

    final doc = await _tasksRef(uid).add(scoredTask.toMap());

    return doc.id;
  }

  Future<void> updateTask(String uid, StudyTask task) async {
    if (task.id.isEmpty) {
      throw ArgumentError('Task id is required for update.');
    }

    _validateTask(task);

    final updated = task.copyWith(
      userId: uid,
      priorityScore: _planner.calculatePriorityScore(task),
      updatedAt: DateTime.now(),
    );

    await _tasksRef(uid).doc(task.id).update(updated.toMap());
  }

  Future<void> deleteTask(String uid, String taskId) {
    return _tasksRef(uid).doc(taskId).delete();
  }

  Future<List<StudyPlanItem>> generateAndSaveWeeklyPlan(
    String uid, {
    DateTime? weekStart,
  }) async {
    final tasksSnapshot = await _tasksRef(uid).get();

    final tasks = tasksSnapshot.docs.map((doc) {
      return StudyTask.fromMap(doc.id, doc.data());
    }).toList();

    final plan = _planner.generateWeeklyPlan(
      tasks: tasks,
      weekStart: weekStart,
    );

    final batch = _firestore.batch();
    final weekKey = _weekKey(weekStart ?? DateTime.now());
    final planRoot = _plansRef(uid).doc(weekKey);

    batch.set(planRoot, {
      'weekStart': Timestamp.fromDate(_startOfWeek(weekStart ?? DateTime.now())),
      'generatedAt': FieldValue.serverTimestamp(),
      'itemCount': plan.length,
    });

    final itemsRef = planRoot.collection('items');

    for (final item in plan) {
      batch.set(itemsRef.doc(item.id), item.toMap());
    }

    await batch.commit();

    return plan;
  }

  Stream<List<StudyPlanItem>> watchWeeklyPlan(String uid, DateTime weekStart) {
    return _plansRef(uid)
        .doc(_weekKey(weekStart))
        .collection('items')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StudyPlanItem.fromMap(doc.id, doc.data())).toList();
    });
  }

  Stream<List<StudyRoom>> watchRooms() {
  return _rooms.orderBy('building').snapshots().map((snapshot) {
    final rooms = snapshot.docs
        .map((doc) => StudyRoom.fromMap(doc.id, doc.data()))
        .toList();

    rooms.sort((a, b) {
      final buildingCompare = a.building.compareTo(b.building);
      if (buildingCompare != 0) return buildingCompare;
      return a.name.compareTo(b.name);
    });

    return rooms;
  });
}

  Future<void> seedDemoRooms() async {
    final now = DateTime.now();

    final rooms = <StudyRoom>[
      StudyRoom(
        id: 'library-101',
        name: 'Library 101',
        building: 'Library',
        capacity: 8,
        occupiedSeats: 2,
        updatedAt: now,
      ),
      StudyRoom(
        id: 'library-202',
        name: 'Library 202',
        building: 'Library',
        capacity: 6,
        occupiedSeats: 6,
        updatedAt: now,
      ),
      StudyRoom(
        id: 'student-center-a',
        name: 'Student Center A',
        building: 'Student Center',
        capacity: 10,
        occupiedSeats: 3,
        updatedAt: now,
      ),
    ];

    final batch = _firestore.batch();

    for (final room in rooms) {
      batch.set(_rooms.doc(room.id), room.toMap());
    }

    await batch.commit();
  }

  Future<void> checkIntoRoom(String roomId) async {
    final ref = _rooms.doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists || snapshot.data() == null) {
        throw StateError('Room does not exist.');
      }

      final room = StudyRoom.fromMap(snapshot.id, snapshot.data()!);

      if (!room.hasAvailableSeats) {
        throw StateError('No seats available in this room.');
      }

      transaction.update(ref, {
        'occupiedSeats': room.occupiedSeats + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> checkOutOfRoom(String roomId) async {
    final ref = _rooms.doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists || snapshot.data() == null) {
        throw StateError('Room does not exist.');
      }

      final room = StudyRoom.fromMap(snapshot.id, snapshot.data()!);
      final nextCount = (room.occupiedSeats - 1).clamp(0, room.capacity);

      transaction.update(ref, {
        'occupiedSeats': nextCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<StudyGroup>> watchGroups() {
    return _groups.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StudyGroup.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<String> createGroup({
    required String ownerId,
    required String name,
    required String courseCode,
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('Group name is required.');
    if (courseCode.trim().isEmpty) throw ArgumentError('Course code is required.');

    final now = DateTime.now();
    final doc = _groups.doc();

    final group = StudyGroup(
      id: doc.id,
      name: name,
      courseCode: courseCode,
      ownerId: ownerId,
      memberIds: [ownerId],
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();

    batch.set(doc, group.toMap());

    batch.set(doc.collection('members').doc(ownerId), {
      'uid': ownerId,
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    await doc.collection('timer').doc('state').set(
          PomodoroState(groupId: doc.id, updatedAt: now).toMap(),
        );

    return doc.id;
  }

  Future<void> joinGroup({
    required String groupId,
    required String uid,
  }) async {
    final groupRef = _groups.doc(groupId);
    final memberRef = groupRef.collection('members').doc(uid);

    final batch = _firestore.batch();

    batch.update(groupRef, {
      'memberIds': FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(memberRef, {
      'uid': uid,
      'role': 'member',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> leaveGroup({
    required String groupId,
    required String uid,
  }) async {
    final groupRef = _groups.doc(groupId);
    final memberRef = groupRef.collection('members').doc(uid);

    final batch = _firestore.batch();

    batch.update(groupRef, {
      'memberIds': FieldValue.arrayRemove([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.delete(memberRef);

    await batch.commit();
  }

  Stream<List<GroupMessage>> watchMessages(String groupId) {
    return _groups
        .doc(groupId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GroupMessage.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    final message = GroupMessage(
      id: '',
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: DateTime.now(),
    );

    await _groups.doc(groupId).collection('messages').add(message.toMap());
  }

  Stream<List<StudySession>> watchSessionsForUser(String uid) {
    return _sessions
        .where('participantIds', arrayContains: uid)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StudySession.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<String> scheduleSession(StudySession session) async {
    if (session.endTime.isBefore(session.startTime) ||
        session.endTime.isAtSameMomentAs(session.startTime)) {
      throw ArgumentError('Session end time must be after start time.');
    }

    final doc = await _sessions.add(session.toMap());

    await _firestore.collection('notificationQueue').add({
      'type': 'session_reminder',
      'sessionId': doc.id,
      'groupId': session.groupId,
      'participantIds': session.participantIds,
      'title': 'Study session reminder',
      'body': '${session.title} starts soon at ${session.location}',
      'sendAt': Timestamp.fromDate(
        session.startTime.subtract(const Duration(minutes: 30)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });

    return doc.id;
  }

  Stream<PomodoroState> watchPomodoroState(String groupId) {
    return _groups.doc(groupId).collection('timer').doc('state').snapshots().map((doc) {
      final data = doc.data();

      if (data == null) {
        return PomodoroState(
          groupId: groupId,
          updatedAt: DateTime.now(),
        );
      }

      return PomodoroState.fromMap(groupId, data);
    });
  }

  Future<void> setPomodoroState(String groupId, PomodoroState state) async {
    await _groups.doc(groupId).collection('timer').doc('state').set(
          state.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> startPomodoro(String groupId, String controlledBy) async {
    await _groups.doc(groupId).collection('timer').doc('state').set({
      'runState': TimerRunState.running.name,
      'controlledBy': controlledBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> pausePomodoro(
    String groupId,
    String controlledBy,
    int remainingSeconds,
  ) async {
    await _groups.doc(groupId).collection('timer').doc('state').set({
      'runState': TimerRunState.paused.name,
      'controlledBy': controlledBy,
      'remainingSeconds': remainingSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetPomodoro(
    String groupId,
    String controlledBy, {
    int seconds = 1500,
  }) async {
    await _groups.doc(groupId).collection('timer').doc('state').set({
      'mode': TimerMode.focus.name,
      'runState': TimerRunState.idle.name,
      'totalSeconds': seconds,
      'remainingSeconds': seconds,
      'controlledBy': controlledBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _validateTask(StudyTask task) {
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title is required.');
    }

    if (task.courseCode.trim().isEmpty) {
      throw ArgumentError('Course code is required.');
    }

    if (task.estimatedHours <= 0) {
      throw ArgumentError('Estimated hours must be greater than zero.');
    }

    if (task.courseWeight < 1 || task.courseWeight > 10) {
      throw ArgumentError('Course weight must be from 1 to 10.');
    }
  }

  String _weekKey(DateTime value) {
    final start = _startOfWeek(value);

    return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
  }

  DateTime _startOfWeek(DateTime value) {
    final date = DateTime(value.year, value.month, value.day);

    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }
}