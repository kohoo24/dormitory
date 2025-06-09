import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../core/utils/logger.dart';

class StayRequestState extends ChangeNotifier {
  UserModel? _user;
  String _currentSemesterId = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _reason = '';
  final TextEditingController _reasonController = TextEditingController();

  // Getters
  UserModel? get user => _user;
  String get currentSemesterId => _currentSemesterId;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  TextEditingController get reasonController => _reasonController;
  String get reason => _reason;

  // Setters with notification
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void setCurrentSemesterId(String semesterId) {
    _currentSemesterId = semesterId;
    notifyListeners();
  }

  void setLoading(bool value) {
    Logger.logStateChange('isLoading', _isLoading, value);
    _isLoading = value;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    Logger.logStateChange('isSubmitting', _isSubmitting, value);
    _isSubmitting = value;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    Logger.logStateChange('startDate', _startDate, date);
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    Logger.logStateChange('endDate', _endDate, date);
    _endDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    Logger.logStateChange('startTime', _startTime, time);
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    Logger.logStateChange('endTime', _endTime, time);
    _endTime = time;
    notifyListeners();
  }

  void updateStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void updateEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void updateStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void updateEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  void updateReason(String value) {
    _reason = value;
    notifyListeners();
  }

  // Reset state
  void reset() {
    Logger.logInfo('Resetting stay request state');
    _startDate = null;
    _endDate = null;
    _startTime = null;
    _endTime = null;
    _reason = '';
    _isSubmitting = false;
    _reasonController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    Logger.logDebug('Disposing stay request state');
    _reasonController.dispose();
    super.dispose();
  }
}
