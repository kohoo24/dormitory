import 'package:cloud_firestore/cloud_firestore.dart';

class EntryLogModel {
  final String id;
  final String userId;
  final String userName;
  final String studentId;
  final String semesterId;
  final DateTime timestamp;
  final String type; // 'entry' or 'exit'
  final bool isManualEntry; // true if manually entered by admin
  final String? adminId; // ID of admin who manually entered the log
  final DateTime createdAt;
  final bool hasActiveStayRequest;

  EntryLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.studentId,
    required this.semesterId,
    required this.timestamp,
    required this.type,
    required this.isManualEntry,
    this.adminId,
    required this.createdAt,
    required this.hasActiveStayRequest,
  });

  factory EntryLogModel.fromJson(Map<String, dynamic> json) {
    return EntryLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      studentId: json['studentId'] as String,
      semesterId: json['semesterId'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      type: json['type'] as String,
      isManualEntry: json['isManualEntry'] as bool,
      adminId: json['adminId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      hasActiveStayRequest: json['hasActiveStayRequest'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'studentId': studentId,
      'semesterId': semesterId,
      'timestamp': timestamp,
      'type': type,
      'isManualEntry': isManualEntry,
      'adminId': adminId,
      'createdAt': createdAt,
      'hasActiveStayRequest': hasActiveStayRequest,
    };
  }

  EntryLogModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? studentId,
    String? semesterId,
    DateTime? timestamp,
    String? type,
    bool? isManualEntry,
    String? adminId,
    DateTime? createdAt,
    bool? hasActiveStayRequest,
  }) {
    return EntryLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      studentId: studentId ?? this.studentId,
      semesterId: semesterId ?? this.semesterId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      hasActiveStayRequest: hasActiveStayRequest ?? this.hasActiveStayRequest,
    );
  }
}
