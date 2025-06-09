import 'package:cloud_firestore/cloud_firestore.dart';

class PenaltyModel {
  final String id;
  final String userId;
  final String userName; // 학생 이름
  final String studentId; // 학번
  final String semesterId;
  final String type;
  final int points;
  final String reason;
  final DateTime date;
  final String? adminId; // ID of admin who issued or modified the penalty
  final bool isAutomatic; // true if automatically assigned by system
  final String status; // 벌점 상태 (active, canceled)
  final String? cancelReason; // 취소 사유 (status가 canceled인 경우)
  final DateTime createdAt;
  final DateTime updatedAt;

  PenaltyModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.studentId,
    required this.semesterId,
    required this.type,
    required this.points,
    required this.reason,
    required this.date,
    this.adminId,
    required this.isAutomatic,
    required this.status,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PenaltyModel.fromJson(Map<String, dynamic> json) {
    return PenaltyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      studentId: json['studentId'] as String,
      semesterId: json['semesterId'] as String,
      type: json['type'] as String,
      points: json['points'] as int,
      reason: json['reason'] as String,
      date: (json['date'] as Timestamp).toDate(),
      adminId: json['adminId'] as String?,
      isAutomatic: json['isAutomatic'] as bool,
      status: json['status'] as String,
      cancelReason: json['cancelReason'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'studentId': studentId,
      'semesterId': semesterId,
      'type': type,
      'points': points,
      'reason': reason,
      'date': date,
      'adminId': adminId,
      'isAutomatic': isAutomatic,
      'status': status,
      'cancelReason': cancelReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PenaltyModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? studentId,
    String? semesterId,
    String? type,
    int? points,
    String? reason,
    DateTime? date,
    String? adminId,
    bool? isAutomatic,
    String? status,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PenaltyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      studentId: studentId ?? this.studentId,
      semesterId: semesterId ?? this.semesterId,
      type: type ?? this.type,
      points: points ?? this.points,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      adminId: adminId ?? this.adminId,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
