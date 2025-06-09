// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stay_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StayRequest _$StayRequestFromJson(Map<String, dynamic> json) => StayRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      studentId: json['studentId'] as String,
      dormRoom: json['dormRoom'] as String,
      startDate: StayRequest._dateTimeFromJson(json['startDate'] as String),
      endDate: StayRequest._dateTimeFromJson(json['endDate'] as String),
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: StayRequest._dateTimeFromJson(json['createdAt'] as String),
      updatedAt: StayRequest._dateTimeFromJson(json['updatedAt'] as String),
      adminComment: json['adminComment'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$StayRequestToJson(StayRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'studentId': instance.studentId,
      'dormRoom': instance.dormRoom,
      'startDate': StayRequest._dateTimeToJson(instance.startDate),
      'endDate': StayRequest._dateTimeToJson(instance.endDate),
      'reason': instance.reason,
      'status': instance.status,
      'adminComment': instance.adminComment,
      'rejectionReason': instance.rejectionReason,
      'createdAt': StayRequest._dateTimeToJson(instance.createdAt),
      'updatedAt': StayRequest._dateTimeToJson(instance.updatedAt),
    };
