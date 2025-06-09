import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/penalty_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class PenaltyService {
  final Uuid _uuid = Uuid();
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  // Create a new penalty
  Future<PenaltyModel> createPenalty({
    required String userId,
    required String userName,
    required String studentId,
    required String semesterId,
    required String type,
    required int points,
    required String reason,
    required DateTime date,
    String? adminId,
    required bool isAutomatic,
    required String status,
  }) async {
    final String id = _uuid.v4();
    final now = DateTime.now();
    final penalty = PenaltyModel(
      id: id,
      userId: userId,
      userName: userName,
      studentId: studentId,
      semesterId: semesterId,
      type: type,
      points: points,
      reason: reason,
      date: date,
      adminId: adminId,
      isAutomatic: isAutomatic,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.setData(
      path: '${AppConstants.penaltiesCollection}/${penalty.id}',
      data: penalty.toJson(),
    );
    // Send notification to user
    final userDoc =
        await _firestore.getDocument('${AppConstants.usersCollection}/$userId');
    if (userDoc.exists) {
      final user = UserModel.fromJson(userDoc.data()!);
      if (user.notificationsEnabled) {
        await _notificationService.sendNotification(
          userId: userId,
          type: AppConstants.notificationPenaltyIssued,
          title: 'Penalty Issued',
          body: 'You have received a penalty of $points points for: $reason',
          data: {
            'penaltyId': penalty.id,
            'points': points,
            'type': type,
          },
        );
      }
    }
    return penalty;
  }

  // Get all penalties for a user
  Stream<List<PenaltyModel>> getUserPenalties(
      String userId, String semesterId) {
    return _firestore.collectionStream<PenaltyModel>(
      path: AppConstants.penaltiesCollection,
      converter: (doc) =>
          PenaltyModel.fromJson(doc.data() as Map<String, dynamic>),
      queryBuilder: (query) => query
          .where('userId', isEqualTo: userId)
          .where('semesterId', isEqualTo: semesterId)
          .orderBy('date', descending: true),
    );
  }

  // Get all penalties for admin
  Stream<List<PenaltyModel>> getAllPenalties(String semesterId) {
    return _firestore.collectionStream<PenaltyModel>(
      path: AppConstants.penaltiesCollection,
      converter: (doc) =>
          PenaltyModel.fromJson(doc.data() as Map<String, dynamic>),
      queryBuilder: (query) => query
          .where('semesterId', isEqualTo: semesterId)
          .orderBy('date', descending: true),
    );
  }

  // Get penalty by ID
  Future<PenaltyModel?> getPenaltyById(String penaltyId) async {
    final doc = await _firestore
        .getDocument('${AppConstants.penaltiesCollection}/$penaltyId');
    if (!doc.exists) return null;
    return PenaltyModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  // Get penalties by date range
  Future<List<PenaltyModel>> getPenaltiesByDateRange({
    required String userId,
    required String semesterId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _firestore
        .collection(AppConstants.penaltiesCollection)
        .where('userId', isEqualTo: userId)
        .where('semesterId', isEqualTo: semesterId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PenaltyModel.fromJson(doc.data()))
        .toList();
  }

  // Update penalty status
  Future<void> updatePenaltyStatus({
    required String penaltyId,
    required String status,
    String? adminComment,
  }) async {
    final Map<String, dynamic> data = {
      'status': status,
      'updatedAt': DateTime.now(),
    };
    if (adminComment != null) {
      data['adminComment'] = adminComment;
    }
    await _firestore.updateData(
      path: '${AppConstants.penaltiesCollection}/$penaltyId',
      data: data,
    );
  }

  // Update penalty
  Future<PenaltyModel> updatePenalty({
    required String penaltyId,
    int? points,
    String? reason,
    required String adminId,
  }) async {
    final Map<String, dynamic> data = {
      'adminId': adminId,
      'isAutomatic': false, // Once modified by admin, it's no longer automatic
      'updatedAt': DateTime.now(),
    };
    if (points != null) data['points'] = points;
    if (reason != null) data['reason'] = reason;
    await _firestore.updateData(
      path: '${AppConstants.penaltiesCollection}/$penaltyId',
      data: data,
    );
    // Get updated penalty data
    final doc = await _firestore
        .getDocument('${AppConstants.penaltiesCollection}/$penaltyId');
    return PenaltyModel.fromJson(doc.data()!);
  }

  // Delete penalty
  Future<void> deletePenalty(String penaltyId) async {
    await _firestore.deleteData('penalties/$penaltyId');
  }

  // Get total penalty points for a user in a semester
  Future<int> getTotalPenaltyPoints(String userId, String semesterId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(AppConstants.penaltiesCollection)
        .where('userId', isEqualTo: userId)
        .where('semesterId', isEqualTo: semesterId)
        .get();
    int totalPoints = 0;
    for (final doc in snapshot.docs) {
      final penalty = PenaltyModel.fromJson(doc.data());
      totalPoints += penalty.points;
    }
    return totalPoints;
  }

  // Check for missing entry logs and assign penalties
  Future<void> checkAndAssignPenalties({
    required String userId,
    required String semesterId,
    required DateTime date,
    required bool hasStayRequest,
    required bool hasEntryLog,
  }) async {
    // If there's no stay request and no entry log, assign penalty
    if (!hasStayRequest && !hasEntryLog) {
      // Get user data to include name and student ID
      final userDoc = await _firestore
          .getDocument('${AppConstants.usersCollection}/$userId');
      String userName = 'Unknown';
      String studentId = 'Unknown';
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userName = userData['name'] as String? ?? 'Unknown';
        studentId = userData['studentId'] as String? ?? 'Unknown';
      }
      await createPenalty(
        userId: userId,
        userName: userName,
        studentId: studentId,
        semesterId: semesterId,
        type: AppConstants.penaltyNoStayRequest,
        points: AppConstants.defaultPenaltyPoints,
        reason: 'No stay request and no entry log for ${_formatDate(date)}',
        date: date,
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
      );
    }
    // If there's no entry log but there is a stay request, the system should not assign a penalty
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
