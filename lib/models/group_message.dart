import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;

  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  factory GroupMessage.fromMap(String id, Map<String, dynamic> data) {
    return GroupMessage(
      id: id,
      groupId: data['groupId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: _dateFrom(data['sentAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text.trim(),
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}

DateTime _dateFrom(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
