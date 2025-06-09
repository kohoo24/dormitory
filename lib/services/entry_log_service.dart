import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/entry/models/entry_log.dart';
import 'firestore_service.dart';

class EntryLogService {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 출입 로그 스트림
  Stream<List<EntryLog>> getEntryLogsStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    return _firestore.collectionStream<EntryLog>(
      path: 'entry_logs',
      converter: (doc) => EntryLog.fromJson(doc.data() as Map<String, dynamic>),
      queryBuilder: (query) => query
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true),
    );
  }

  // 관리자용 전체 출입 로그 스트림
  Stream<List<EntryLog>> getAllEntryLogsStream() {
    return _firestore.collectionStream<EntryLog>(
      path: 'entry_logs',
      converter: (doc) => EntryLog.fromJson(doc.data() as Map<String, dynamic>),
      queryBuilder: (query) => query.orderBy('timestamp', descending: true),
    );
  }

  // 출입 로그 추가
  Future<void> addEntryLog(EntryLog log) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    await _firestore.setData(
      path: 'entry_logs/${log.id}',
      data: log.toJson(),
    );
  }

  // 출입 로그 업데이트
  Future<void> updateEntryLog(String logId, EntryLog log) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    await _firestore.setData(
      path: 'entry_logs/$logId',
      data: log.toJson(),
    );
  }

  // 출입 로그 삭제
  Future<void> deleteEntryLog(String logId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    await _firestore.deleteData('entry_logs/$logId');
  }

  // 특정 사용자의 출입 로그 조회
  Future<List<EntryLog>> getUserEntryLogs(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final snapshot = await _firestore
        .collection('entry_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => EntryLog.fromJson(doc.data())).toList();
  }

  // 특정 기간의 출입 로그 조회
  Future<List<EntryLog>> getEntryLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final snapshot = await _firestore
        .collection('entry_logs')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => EntryLog.fromJson(doc.data())).toList();
  }

  // 특정 사용자의 특정 기간 출입 로그 조회
  Future<List<EntryLog>> getUserEntryLogsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final snapshot = await _firestore
        .collection('entry_logs')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => EntryLog.fromJson(doc.data())).toList();
  }

  // 특정 출입 로그 조회
  Future<EntryLog?> getEntryLog(String logId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final doc = await _firestore.getDocument('entry_logs/$logId');
    if (!doc.exists) return null;

    return EntryLog.fromJson(doc.data() as Map<String, dynamic>);
  }

  // 출입 로그 검색
  Future<List<EntryLog>> searchEntryLogs(String query) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final snapshot = await _firestore
        .collection('entry_logs')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EntryLog.fromJson(doc.data()))
        .where((log) =>
            log.userName.toLowerCase().contains(query.toLowerCase()) ||
            (log.reason?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }
}
