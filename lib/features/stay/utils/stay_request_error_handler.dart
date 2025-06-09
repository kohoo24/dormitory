import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../constants/stay_request_constants.dart';

/// 외박 신청 관련 오류를 처리하는 클래스입니다.
class StayRequestErrorHandler {
  /// 오류 메시지를 표시합니다.
  static void showError(BuildContext context, String message) {
    Logger.logError('외박 신청 오류: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 성공 메시지를 표시합니다.
  static void showSuccess(BuildContext context, String message) {
    Logger.logInfo('외박 신청 성공: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 경고 메시지를 표시합니다.
  static void showWarning(BuildContext context, String message) {
    Logger.logWarning('외박 신청 경고: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 외박 신청 유효성을 검사합니다.
  static String? getValidationErrorMessage({
    required DateTime? startDate,
    required DateTime? endDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String reason,
  }) {
    if (startDate == null || endDate == null) {
      return '외박 날짜를 선택해주세요.';
    }

    if (startTime == null || endTime == null) {
      return '외박 시간을 선택해주세요.';
    }

    final now = DateTime.now();
    if (startDate.isBefore(now)) {
      return '시작일은 오늘 이후여야 합니다.';
    }

    if (endDate.isBefore(startDate)) {
      return '종료일은 시작일 이후여야 합니다.';
    }

    final duration = endDate.difference(startDate).inDays;
    if (duration > StayRequestConstants.maxStayDuration) {
      return '최대 외박 기간은 ${StayRequestConstants.maxStayDuration}일입니다.';
    }

    if (duration < StayRequestConstants.minStayDuration) {
      return '최소 외박 기간은 ${StayRequestConstants.minStayDuration}일입니다.';
    }

    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      return '종료 시간은 시작 시간 이후여야 합니다.';
    }

    if (reason.isEmpty) {
      return '외박 이유를 입력해주세요.';
    }

    if (reason.length < StayRequestConstants.minReasonLength) {
      return '외박 이유는 최소 ${StayRequestConstants.minReasonLength}자 이상 입력해주세요.';
    }

    if (reason.length > StayRequestConstants.maxReasonLength) {
      return '외박 이유는 최대 ${StayRequestConstants.maxReasonLength}자까지 입력 가능합니다.';
    }

    return null;
  }
}
