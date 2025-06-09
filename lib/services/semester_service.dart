import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/semester_model.dart';
import 'firebase_service.dart';

class SemesterService {
  // Get active semester
  static Future<SemesterModel?> getActiveSemester() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseService.collection(AppConstants.semestersCollection)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      return null;
    }
    
    final doc = snapshot.docs.first;
    final semester = SemesterModel.fromJson(doc.data());
    
    // Save current semester ID to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefCurrentSemesterId, semester.id);
    
    return semester;
  }
  
  // Get current semester ID from shared preferences
  static Future<String?> getCurrentSemesterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefCurrentSemesterId);
  }
  
  // Get current semester
  static Future<SemesterModel?> getCurrentSemester() async {
    final currentSemesterId = await getCurrentSemesterId();
    if (currentSemesterId == null) {
      return getActiveSemester();
    }
    return getSemesterById(currentSemesterId);
  }
  
  // Get semester by ID
  static Future<SemesterModel?> getSemesterById(String semesterId) async {
    final doc = await FirebaseService.document('${AppConstants.semestersCollection}/$semesterId').get();
    
    if (!doc.exists) {
      return null;
    }
    
    return SemesterModel.fromJson(doc.data()!);
  }
  
  // Create new semester
  static Future<SemesterModel> createSemester({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) async {
    // If this semester is active, deactivate all other semesters
    if (isActive) {
      await _deactivateAllSemesters();
    }
    
    final String id = FirebaseService.firestore.collection(AppConstants.semestersCollection).doc().id;
    
    final semester = SemesterModel(
      id: id,
      name: name,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await FirebaseService.setData(
      path: '${AppConstants.semestersCollection}/${semester.id}',
      data: semester.toJson(),
    );
    
    // If active, save to shared preferences
    if (isActive) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefCurrentSemesterId, semester.id);
    }
    
    return semester;
  }
  
  // Update semester
  static Future<SemesterModel> updateSemester({
    required String semesterId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    // If setting this semester to active, deactivate all others
    if (isActive == true) {
      await _deactivateAllSemesters();
    }
    
    final Map<String, dynamic> data = {
      'updatedAt': DateTime.now(),
    };
    
    if (name != null) data['name'] = name;
    if (startDate != null) data['startDate'] = startDate;
    if (endDate != null) data['endDate'] = endDate;
    if (isActive != null) data['isActive'] = isActive;
    
    await FirebaseService.updateData(
      path: '${AppConstants.semestersCollection}/$semesterId',
      data: data,
    );
    
    // If setting to active, update shared preferences
    if (isActive == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefCurrentSemesterId, semesterId);
    }
    
    // Get updated semester data
    final doc = await FirebaseService.document('${AppConstants.semestersCollection}/$semesterId').get();
    return SemesterModel.fromJson(doc.data()!);
  }
  
  // Get all semesters
  static Stream<List<SemesterModel>> getAllSemesters() {
    return FirebaseService.collectionStream(
      path: AppConstants.semestersCollection,
      builder: (data, documentId) => SemesterModel.fromJson(data),
      sort: (a, b) => b.startDate.compareTo(a.startDate), // Sort by start date descending
    );
  }
  
  // Helper method to deactivate all semesters
  static Future<void> _deactivateAllSemesters() async {
    final batch = FirebaseService.firestore.batch();
    
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseService.collection(AppConstants.semestersCollection)
        .where('isActive', isEqualTo: true)
        .get();
    
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    }
    
    await batch.commit();
  }
}
