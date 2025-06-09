import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String studentId;
  final String role;
  final String dormRoom;
  final String phoneNumber;
  final String languageCode;
  final bool notificationsEnabled;
  final String? currentSemesterId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.studentId,
    required this.role,
    required this.dormRoom,
    required this.phoneNumber,
    required this.languageCode,
    required this.notificationsEnabled,
    this.currentSemesterId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    return UserModel(
      id: json['id'] as String? ?? json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      role: json['role'] as String? ?? '',
      dormRoom: json['dormRoom'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'ko',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      currentSemesterId: json['currentSemesterId'] as String?,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'studentId': studentId,
      'role': role,
      'dormRoom': dormRoom,
      'phoneNumber': phoneNumber,
      'languageCode': languageCode,
      'notificationsEnabled': notificationsEnabled,
      'currentSemesterId': currentSemesterId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? studentId,
    String? role,
    String? dormRoom,
    String? phoneNumber,
    String? languageCode,
    bool? notificationsEnabled,
    String? currentSemesterId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      dormRoom: dormRoom ?? this.dormRoom,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentSemesterId: currentSemesterId ?? this.currentSemesterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
