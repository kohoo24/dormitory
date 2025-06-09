/// 외박 신청 화면에서 사용되는 상수들을 정의합니다.
class StayRequestConstants {
  /// 카드의 테두리 반경
  static const double cardBorderRadius = 16.0;

  /// 버튼의 높이
  static const double buttonHeight = 56.0;

  /// 입력 필드의 최소 높이
  static const double inputFieldHeight = 48.0;

  /// 날짜 선택기의 최소 날짜 (현재 날짜)
  static const int minDateDays = 0;

  /// 날짜 선택기의 최대 날짜 (현재 날짜로부터 30일)
  static const int maxDateDays = 30;

  /// 시간 선택기의 최소 시간 (오전 6시)
  static const int minHour = 6;

  /// 시간 선택기의 최대 시간 (오후 10시)
  static const int maxHour = 22;

  /// 외박 신청 제출 마감 시간 (오후 5시)
  static const int cutoffHour = 17;

  /// 외박 신청 사유 최소 길이
  static const int minReasonLength = 10;

  /// 외박 신청 사유 최대 길이
  static const int maxReasonLength = 500;

  /// 외박 신청 사유 입력 필드의 최대 라인 수
  static const int maxReasonLines = 5;

  /// 외박 신청 사유 입력 필드의 힌트 텍스트
  static const String reasonHint = '외박 사유를 입력해주세요 (10자 이상)';

  /// 외박 신청 제출 버튼 텍스트
  static const String submitButtonText = '외박 신청하기';

  /// 외박 신청 취소 버튼 텍스트
  static const String cancelButtonText = '취소';

  /// 외박 신청 성공 메시지
  static const String successMessage = '외박 신청이 완료되었습니다.';

  /// 외박 신청 실패 메시지
  static const String errorMessage = '외박 신청 중 오류가 발생했습니다.';

  /// 외박 신청 마감 시간 경고 메시지
  static const String cutoffWarningMessage = '오후 5시 이후에는 당일 외박 신청이 불가능합니다.';

  /// 외박 신청 사유 길이 경고 메시지
  static const String reasonLengthWarningMessage =
      '외박 사유는 10자 이상 500자 이하로 입력해주세요.';

  /// 외박 신청 날짜 경고 메시지
  static const String dateWarningMessage = '외박 시작일은 종료일보다 이전이어야 합니다.';

  /// 외박 신청 시간 경고 메시지
  static const String timeWarningMessage = '외박 시간은 오전 6시부터 오후 10시 사이여야 합니다.';

  /// 최대 외박 기간 (일)
  static const int maxStayDuration = 30;

  /// 최소 외박 기간 (일)
  static const int minStayDuration = 1;
}
