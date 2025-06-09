import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:capstone250423/features/stay/state/stay_request_state.dart';
import 'package:capstone250423/features/stay/utils/stay_request_error_handler.dart';
import 'package:capstone250423/features/stay/constants/stay_request_constants.dart';

void main() {
  group('StayRequestState Tests', () {
    late StayRequestState stayRequestState;

    setUp(() {
      stayRequestState = StayRequestState();
    });

    test('초기 상태 테스트', () {
      expect(stayRequestState.isLoading, false);
      expect(stayRequestState.isSubmitting, false);
      expect(stayRequestState.startDate, null);
      expect(stayRequestState.endDate, null);
      expect(stayRequestState.startTime, null);
      expect(stayRequestState.endTime, null);
      expect(stayRequestState.reasonController.text, '');
    });

    test('날짜 설정 테스트', () {
      final now = DateTime.now();
      stayRequestState.setStartDate(now);
      stayRequestState.setEndDate(now.add(const Duration(days: 1)));

      expect(stayRequestState.startDate, now);
      expect(stayRequestState.endDate?.difference(now).inDays, 1);
    });

    test('시간 설정 테스트', () {
      const time = TimeOfDay(hour: 14, minute: 30);
      stayRequestState.setStartTime(time);
      stayRequestState.setEndTime(time);

      expect(stayRequestState.startTime?.hour, 14);
      expect(stayRequestState.startTime?.minute, 30);
      expect(stayRequestState.endTime?.hour, 14);
      expect(stayRequestState.endTime?.minute, 30);
    });

    test('상태 초기화 테스트', () {
      final now = DateTime.now();
      const time = TimeOfDay(hour: 14, minute: 30);

      stayRequestState.setStartDate(now);
      stayRequestState.setEndDate(now);
      stayRequestState.setStartTime(time);
      stayRequestState.setEndTime(time);
      stayRequestState.reasonController.text = '테스트 이유';

      stayRequestState.reset();

      expect(stayRequestState.startDate, null);
      expect(stayRequestState.endDate, null);
      expect(stayRequestState.startTime, null);
      expect(stayRequestState.endTime, null);
      expect(stayRequestState.reasonController.text, '');
    });
  });

  group('StayRequestErrorHandler Tests', () {
    test('날짜 유효성 검사 테스트', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));
      final tooFarFuture = now
          .add(const Duration(days: StayRequestConstants.maxStayDuration + 1));

      expect(
        StayRequestErrorHandler.getValidationErrorMessage(
          startDate: yesterday,
          endDate: now,
          startTime: TimeOfDay.now(),
          endTime: TimeOfDay.now(),
          reason: '테스트',
        ),
        contains('시작일은 오늘 이후여야 합니다'),
      );

      expect(
        StayRequestErrorHandler.getValidationErrorMessage(
          startDate: tomorrow,
          endDate: now,
          startTime: TimeOfDay.now(),
          endTime: TimeOfDay.now(),
          reason: '테스트',
        ),
        contains('종료일은 시작일 이후여야 합니다'),
      );

      expect(
        StayRequestErrorHandler.getValidationErrorMessage(
          startDate: now,
          endDate: tooFarFuture,
          startTime: TimeOfDay.now(),
          endTime: TimeOfDay.now(),
          reason: '테스트',
        ),
        contains('최대 외박 기간은'),
      );
    });

    test('시간 유효성 검사 테스트', () {
      final now = DateTime.now();
      const startTime = TimeOfDay(hour: 14, minute: 0);
      const endTime = TimeOfDay(hour: 13, minute: 0);

      expect(
        StayRequestErrorHandler.getValidationErrorMessage(
          startDate: now,
          endDate: now,
          startTime: startTime,
          endTime: endTime,
          reason: '테스트',
        ),
        contains('종료 시간은 시작 시간 이후여야 합니다'),
      );
    });

    test('이유 입력 유효성 검사 테스트', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      expect(
        StayRequestErrorHandler.getValidationErrorMessage(
          startDate: now,
          endDate: tomorrow,
          startTime: TimeOfDay.now(),
          endTime: TimeOfDay.now(),
          reason: '',
        ),
        contains('외박 이유를 입력해주세요'),
      );
    });
  });
}
