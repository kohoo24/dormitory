/// 외박 신청 관련 문자열을 관리하는 클래스입니다.
class StayRequestStrings {
  static const Map<String, String> ko = {
    // 타이틀
    'stay_request_title': '외박 신청',
    'stay_request_subtitle': '외박 일정을 선택해주세요',

    // 날짜 선택
    'start_date': '시작일',
    'end_date': '종료일',
    'start_time': '출발 시간',
    'end_time': '귀가 시간',
    'select_date': '날짜 선택',
    'select_time': '시간 선택',

    // 입력 필드
    'reason_hint': '외박 사유를 입력해주세요',
    'reason_label': '외박 사유',

    // 버튼
    'submit': '신청하기',
    'cancel': '취소',
    'confirm': '확인',

    // 유효성 검사 메시지
    'error_start_date_required': '시작일을 선택해주세요',
    'error_end_date_required': '종료일을 선택해주세요',
    'error_start_time_required': '출발 시간을 선택해주세요',
    'error_end_time_required': '귀가 시간을 선택해주세요',
    'error_reason_required': '외박 사유를 입력해주세요',
    'error_start_date_past': '시작일은 오늘 이후여야 합니다',
    'error_end_date_before_start': '종료일은 시작일 이후여야 합니다',
    'error_end_time_before_start': '종료 시간은 시작 시간 이후여야 합니다',
    'error_max_duration': '최대 외박 기간은 {days}일입니다',
    'error_late_submission': '오후 5시 이후 당일 외박 신청은 사감 선생님께 직접 문의해주세요',

    // 상태 메시지
    'submitting': '신청 중...',
    'submit_success': '외박 신청이 완료되었습니다',
    'submit_error': '외박 신청 중 오류가 발생했습니다',
    'network_error': '네트워크 연결을 확인해주세요',
    'server_error': '서버 오류가 발생했습니다',
    'unknown_error': '알 수 없는 오류가 발생했습니다',

    // 경고 메시지
    'warning_title': '주의',
    'warning_late_submission': '오후 5시 이후의 당일 외박 신청입니다.\n계속하시겠습니까?',
    'warning_long_stay': '{days}일 이상의 장기 외박입니다.\n계속하시겠습니까?',
  };

  static const Map<String, String> en = {
    // Titles
    'stay_request_title': 'Stay Request',
    'stay_request_subtitle': 'Select your stay schedule',

    // Date Selection
    'start_date': 'Start Date',
    'end_date': 'End Date',
    'start_time': 'Departure Time',
    'end_time': 'Return Time',
    'select_date': 'Select Date',
    'select_time': 'Select Time',

    // Input Fields
    'reason_hint': 'Enter reason for stay',
    'reason_label': 'Reason',

    // Buttons
    'submit': 'Submit',
    'cancel': 'Cancel',
    'confirm': 'Confirm',

    // Validation Messages
    'error_start_date_required': 'Please select start date',
    'error_end_date_required': 'Please select end date',
    'error_start_time_required': 'Please select departure time',
    'error_end_time_required': 'Please select return time',
    'error_reason_required': 'Please enter reason for stay',
    'error_start_date_past': 'Start date must be after today',
    'error_end_date_before_start': 'End date must be after start date',
    'error_end_time_before_start': 'Return time must be after departure time',
    'error_max_duration': 'Maximum stay duration is {days} days',
    'error_late_submission':
        'For same-day requests after 5 PM, please contact the dormitory supervisor directly',

    // Status Messages
    'submitting': 'Submitting...',
    'submit_success': 'Stay request submitted successfully',
    'submit_error': 'Error submitting stay request',
    'network_error': 'Please check your network connection',
    'server_error': 'Server error occurred',
    'unknown_error': 'Unknown error occurred',

    // Warning Messages
    'warning_title': 'Warning',
    'warning_late_submission':
        'This is a same-day request after 5 PM.\nDo you want to continue?',
    'warning_long_stay':
        'This is a long-term stay of {days} days or more.\nDo you want to continue?',
  };
}
