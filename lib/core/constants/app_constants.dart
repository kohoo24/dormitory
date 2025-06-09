class AppConstants {
  // App information
  static const String appName = 'Dorm Stay Manager';
  static const String appVersion = '1.0.0';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String semestersCollection = 'semesters';
  static const String stayRequestsCollection = 'stayRequests';
  static const String entryLogsCollection = 'entryLogs';
  static const String penaltiesCollection = 'penalties';
  static const String notificationsCollection = 'notifications';

  // User roles
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Stay request status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusCancelled = 'cancelled';

  // Penalty types
  static const String penaltyNoStayRequest = 'no_stay_request';
  static const String penaltyLateReturn = 'late_return';
  static const String penaltyNoCardTag = 'no_card_tag';
  static const String penaltyOther = 'other';

  // Penalty status
  static const String penaltyStatusActive = 'active';
  static const String penaltyStatusCanceled = 'canceled';

  // Entry log types
  static const String entryTypeEntry = 'entry';
  static const String entryTypeExit = 'exit';

  // Notification types
  static const String notificationStayRequestApproved = 'stay_request_approved';
  static const String notificationStayRequestRejected = 'stay_request_rejected';
  static const String notificationReturnReminder = 'return_reminder';
  static const String notificationPenaltyIssued = 'penalty_issued';

  // Shared preferences keys
  static const String prefLanguageCode = 'language_code';
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefCurrentSemesterId = 'current_semester_id';

  // Default values
  static const String defaultLanguage = 'ko';
  static const int defaultStayRequestCutoffHour = 17; // 5 PM
  static const int defaultPenaltyPoints = 3;

  // UI Constants
  static const double tabBarHeight = 50.0;
  static const double safeAreaBottom = 34.0;
  static const double notchHeight = 44.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Grid layout (iOS app grid based on requirements)
  static const int gridColumns = 8;
  static const double gridGutter = 16.0;
  static const double gridMarginLeft = 33.0;
  static const double gridMarginRight = 47.0;

  // API 관련 상수
  static const String apiBaseUrl = 'https://api.dormitory.example.com/v1';

  // 현재 학기 ID (실제 구현에서는 동적으로 가져와야 함)
  static const String currentSemesterId = '2024-1';
}
