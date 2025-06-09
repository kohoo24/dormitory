// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntryLog _$EntryLogFromJson(Map<String, dynamic> json) => EntryLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      studentId: json['studentId'] as String,
      semesterId: json['semesterId'] as String,
      timestamp: EntryLog._dateTimeFromJson(json['timestamp'] as Timestamp),
      type: json['type'] as String,
      isManualEntry: json['isManualEntry'] as bool,
      adminId: json['adminId'] as String?,
      createdAt: EntryLog._dateTimeFromJson(json['createdAt'] as Timestamp),
      hasActiveStayRequest: json['hasActiveStayRequest'] as bool,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$EntryLogToJson(EntryLog instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'studentId': instance.studentId,
      'semesterId': instance.semesterId,
      'timestamp': EntryLog._dateTimeToJson(instance.timestamp),
      'type': instance.type,
      'isManualEntry': instance.isManualEntry,
      'adminId': instance.adminId,
      'createdAt': EntryLog._dateTimeToJson(instance.createdAt),
      'hasActiveStayRequest': instance.hasActiveStayRequest,
      'reason': instance.reason,
    };
