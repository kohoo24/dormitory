class ApiConstants {
  // Firebase Functions API URL
  static const String baseUrl =
      'https://us-central1-dormitory-project.cloudfunctions.net/api';

  // API Endpoints
  static const String auth = '/auth';
  static const String user = '/user';
  static const String stay = '/stay';
  static const String entry = '/entry';
  static const String penalty = '/penalty';

  // Stay Request Endpoints
  static const String submitStay = '/submit';
  static const String stayHistory = '/history';
  static const String updateStay = '/update';
  static const String cancelStay = '/cancel';

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String refreshToken = '/refresh';

  // HTTP Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
