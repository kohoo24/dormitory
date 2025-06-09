import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entry_log.g.dart';

@JsonSerializable()
class EntryLog {
  final String id;
  final String userId;
  final String userName;
  final String studentId;
  final String semesterId;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;
  final String type;
  final bool isManualEntry;
  final String? adminId;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  final bool hasActiveStayRequest;
  final String? reason;

  EntryLog({
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
    this.reason,
  });

  factory EntryLog.fromJson(Map<String, dynamic> json) =>
      _$EntryLogFromJson(json);
  Map<String, dynamic> toJson() => _$EntryLogToJson(this);

  static DateTime _dateTimeFromJson(Timestamp timestamp) => timestamp.toDate();
  static Timestamp _dateTimeToJson(DateTime date) => Timestamp.fromDate(date);

  EntryLog copyWith({
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
    String? reason,
  }) {
    return EntryLog(
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
      reason: reason ?? this.reason,
    );
  }
}
