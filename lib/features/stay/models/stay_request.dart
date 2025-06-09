import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';

part 'stay_request.g.dart';

@JsonSerializable()
class StayRequest {
  final String id;
  final String userId;
  final String userName;
  final String studentId;
  final String dormRoom;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime startDate;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime endDate;
  final String reason;
  final String status;
  String? adminComment;
  String? rejectionReason;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  StayRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.studentId,
    required this.dormRoom,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.adminComment,
    this.rejectionReason,
  });

  factory StayRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Firebase에서 가져온 데이터 구조에 맞게 변환
      final data = Map<String, dynamic>.from(json);

      // 날짜 문자열을 DateTime으로 변환
      data['startDate'] = _dateTimeFromJson(data['startDate'] as String);
      data['endDate'] = _dateTimeFromJson(data['endDate'] as String);
      data['createdAt'] = _dateTimeFromJson(data['createdAt'] as String);
      data['updatedAt'] = _dateTimeFromJson(data['updatedAt'] as String);

      return _$StayRequestFromJson(data);
    } catch (e) {
      debugPrint('StayRequest.fromJson 오류: $e');
      debugPrint('입력 데이터: $json');

      // 기본값으로 생성
      final now = DateTime.now();
      return StayRequest(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        userName: json['userName'] as String? ?? '',
        studentId: json['studentId'] as String? ?? '',
        dormRoom: json['dormRoom'] as String? ?? '미배정',
        startDate: _dateTimeFromJson(
            json['startDate'] as String? ?? now.toIso8601String()),
        endDate: _dateTimeFromJson(
            json['endDate'] as String? ?? now.toIso8601String()),
        reason: json['reason'] as String? ?? '',
        status: json['status'] as String? ?? AppConstants.statusPending,
        createdAt: _dateTimeFromJson(
            json['createdAt'] as String? ?? now.toIso8601String()),
        updatedAt: _dateTimeFromJson(
            json['updatedAt'] as String? ?? now.toIso8601String()),
        adminComment: json['adminComment'] as String?,
        rejectionReason: json['rejectionReason'] as String?,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = _$StayRequestToJson(this);
    // DateTime을 ISO 8601 문자열로 변환
    data['startDate'] = _dateTimeToJson(startDate);
    data['endDate'] = _dateTimeToJson(endDate);
    data['createdAt'] = _dateTimeToJson(createdAt);
    data['updatedAt'] = _dateTimeToJson(updatedAt);
    return data;
  }

  static DateTime _dateTimeFromJson(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      debugPrint('날짜 파싱 오류: $e');
      return DateTime.now();
    }
  }

  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  StayRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? studentId,
    String? dormRoom,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminComment,
    String? rejectionReason,
  }) {
    return StayRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      studentId: studentId ?? this.studentId,
      dormRoom: dormRoom ?? this.dormRoom,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminComment: adminComment ?? this.adminComment,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // 외박 기간을 계산합니다.
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  // 당일 외박 여부를 확인합니다.
  bool get isSameDay =>
      startDate.year == endDate.year &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day;

  // 오후 5시 이후 신청 여부를 확인합니다.
  bool get isLateSubmission {
    final now = DateTime.now();
    return isSameDay &&
        now.hour >= 17 &&
        startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }
}
