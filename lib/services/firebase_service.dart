import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  static FirebaseAuth get auth => _auth;
  static FirebaseDatabase get database => _database;
  static fs.FirebaseFirestore get firestore => _firestore;

  // 데이터베이스 연결 테스트
  static Future<void> testDatabaseConnection() async {
    try {
      print('데이터베이스 연결 테스트 시작...');

      // 현재 인증 상태 확인
      final user = _auth.currentUser;
      print('현재 인증 상태: ${user != null ? '로그인됨' : '로그인되지 않음'}');
      if (user != null) {
        print('사용자 ID: ${user.uid}');
      }

      // 테스트 데이터
      final testData = {
        'test': 'Hello Firebase',
        'timestamp': ServerValue.timestamp,
      };

      // 테스트 경로
      final testPath = 'test/${DateTime.now().millisecondsSinceEpoch}';
      print('테스트 경로: $testPath');

      // 데이터 저장 시도
      print('데이터 저장 시도...');
      final reference = _database.ref(testPath);
      await reference.set(testData);

      // 저장된 데이터 확인
      print('저장된 데이터 확인...');
      final snapshot = await reference.get();
      if (!snapshot.exists) {
        throw Exception('데이터가 저장되지 않았습니다.');
      }

      print('데이터베이스 연결 테스트 성공!');
      print('저장된 데이터: ${snapshot.value}');

      // 테스트 데이터 삭제
      print('테스트 데이터 삭제...');
      await reference.remove();
      print('테스트 데이터 삭제 완료');
    } catch (e) {
      print('데이터베이스 연결 테스트 실패: $e');
      rethrow;
    }
  }

  // 실제 데이터 저장 테스트
  static Future<void> testRealDataStorage() async {
    try {
      print('실제 데이터 저장 테스트 시작...');

      // 테스트 사용자 데이터
      final userData = {
        'name': '테스트 사용자',
        'email': 'test@example.com',
        'role': 'student',
        'createdAt': ServerValue.timestamp,
      };

      // 사용자 데이터 저장
      final userPath =
          'test/users/test_user_${DateTime.now().millisecondsSinceEpoch}';
      print('사용자 데이터 저장 시도: $userPath');

      final userRef = _database.ref(userPath);
      await userRef.set(userData);

      // 저장된 데이터 확인
      final userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        throw Exception('사용자 데이터가 저장되지 않았습니다.');
      }

      print('사용자 데이터 저장 성공!');
      print('저장된 사용자 데이터: ${userSnapshot.value}');

      // 테스트 외박 신청 데이터
      final stayRequestData = {
        'userId': 'test_user',
        'date': DateTime.now().toIso8601String(),
        'reason': '테스트 외박 신청',
        'status': 'pending',
        'createdAt': ServerValue.timestamp,
      };

      // 외박 신청 데이터 저장
      final stayRequestPath =
          'test/stay_requests/test_request_${DateTime.now().millisecondsSinceEpoch}';
      print('외박 신청 데이터 저장 시도: $stayRequestPath');

      final stayRequestRef = _database.ref(stayRequestPath);
      await stayRequestRef.set(stayRequestData);

      // 저장된 데이터 확인
      final stayRequestSnapshot = await stayRequestRef.get();
      if (!stayRequestSnapshot.exists) {
        throw Exception('외박 신청 데이터가 저장되지 않았습니다.');
      }

      print('외박 신청 데이터 저장 성공!');
      print('저장된 외박 신청 데이터: ${stayRequestSnapshot.value}');
    } catch (e) {
      print('실제 데이터 저장 테스트 실패: $e');
      rethrow;
    }
  }

  // Firebase initialization
  static Future<void> initializeFirebase() async {
    print('Firebase 서비스 초기화 시작...');

    // 테스트 계정으로 로그인
    try {
      print('테스트 계정 로그인 시도...');
      await _auth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test1234',
      );
      print('테스트 계정 로그인 성공');
    } catch (e) {
      print('테스트 계정 로그인 실패: $e');
      // 로그인 실패해도 계속 진행
    }

    // 데이터베이스 연결 테스트
    await testDatabaseConnection();

    // 실제 데이터 저장 테스트
    await testRealDataStorage();

    // Request notification permissions
    print('알림 권한 요청...');
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('알림 권한 설정 완료');
  }

  // Auth methods
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firebase Messaging methods
  static Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  static Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      final reference = _database.ref(path);
      await reference.set(data);

      // 데이터가 제대로 저장되었는지 확인
      final snapshot = await reference.get();
      if (!snapshot.exists) {
        throw Exception('데이터가 저장되지 않았습니다.');
      }

      debugPrint('데이터 저장 성공: $path');
      debugPrint('저장된 데이터: ${snapshot.value}');
    } catch (e) {
      debugPrint('데이터 저장 실패: $e');
      rethrow;
    }
  }

  static Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = _database.ref(path);
      await reference.update(data);

      // 데이터가 제대로 업데이트되었는지 확인
      final snapshot = await reference.get();
      if (!snapshot.exists) {
        throw Exception('데이터가 업데이트되지 않았습니다.');
      }

      debugPrint('데이터 업데이트 성공: $path');
      debugPrint('업데이트된 데이터: ${snapshot.value}');
    } catch (e) {
      debugPrint('데이터 업데이트 실패: $e');
      rethrow;
    }
  }

  static Future<void> deleteData({
    required String path,
  }) async {
    try {
      final reference = _database.ref(path);
      await reference.remove();

      // 데이터가 제대로 삭제되었는지 확인
      final snapshot = await reference.get();
      if (snapshot.exists) {
        throw Exception('데이터가 삭제되지 않았습니다.');
      }

      debugPrint('데이터 삭제 성공: $path');
    } catch (e) {
      debugPrint('데이터 삭제 실패: $e');
      rethrow;
    }
  }

  static Stream<DatabaseEvent> streamData(String path) {
    final reference = _database.ref(path);
    return reference.onValue;
  }

  static Future<DatabaseEvent> getData(String path) async {
    final reference = _database.ref(path);
    return await reference.once();
  }

  // Firestore methods
  static fs.CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  static fs.DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  static Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    List<
            fs.Query<Map<String, dynamic>> Function(
                fs.Query<Map<String, dynamic>>)>?
        queryBuilders,
    int Function(T a, T b)? sort,
  }) {
    fs.Query<Map<String, dynamic>> query = _firestore.collection(path);

    if (queryBuilders != null) {
      for (var builder in queryBuilders) {
        query = builder(query);
      }
    }

    return query.snapshots().map((snapshot) {
      final items =
          snapshot.docs.map((doc) => builder(doc.data(), doc.id)).toList();

      if (sort != null) {
        items.sort(sort);
      }

      return items;
    });
  }
}
