import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 앱의 로깅을 담당하는 유틸리티 클래스입니다.
class Logger {
  static const String _tag = 'StayRequest';

  /// 디버그 로그를 출력합니다.
  static void logDebug(String message) {
    if (kDebugMode) {
      developer.log('🔍 $message', name: _tag);
    }
  }

  /// 정보 로그를 출력합니다.
  static void logInfo(String message) {
    if (kDebugMode) {
      developer.log('ℹ️ $message', name: _tag);
    }
  }

  /// 경고 로그를 출력합니다.
  static void logWarning(String message) {
    if (kDebugMode) {
      developer.log('⚠️ $message', name: _tag);
    }
  }

  /// 에러 로그를 출력합니다.
  static void logError(String message,
      [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        error: error,
        stackTrace: stackTrace,
        name: _tag,
      );
    }
  }

  /// API 요청 로그를 출력합니다.
  static void logApi(String method, String endpoint, {dynamic body}) {
    if (kDebugMode) {
      developer.log(
        '🌐 API Request: $method $endpoint',
        name: _tag,
        error: body != null ? 'Body: $body' : null,
      );
    }
  }

  /// API 응답 로그를 출력합니다.
  static void logApiResponse(
      String endpoint, int statusCode, dynamic response) {
    if (kDebugMode) {
      developer.log(
        '🌐 API Response: $endpoint (Status: $statusCode)',
        name: _tag,
        error: response != null ? 'Response: $response' : null,
      );
    }
  }

  /// 상태 변경 로그를 출력합니다.
  static void logStateChange(
      String stateName, dynamic oldValue, dynamic newValue) {
    if (kDebugMode) {
      developer.log(
        '🔄 State Change: $stateName',
        name: _tag,
        error: 'Old: $oldValue -> New: $newValue',
      );
    }
  }

  /// 사용자 액션 로그를 출력합니다.
  static void logUserAction(String action, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      developer.log(
        '👤 User Action: $action',
        name: _tag,
        error: details != null ? 'Details: $details' : null,
      );
    }
  }
}
