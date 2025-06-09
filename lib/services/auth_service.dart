import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 사용자 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .document('${AppConstants.usersCollection}/${user.uid}')
        .get();
    if (!doc.exists) return null;

    return doc.data();
  }

  // 현재 사용자 모델 가져오기
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // 이메일/비밀번호로 회원가입
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('사용자 생성에 실패했습니다.');

      // FCM 토큰 가져오기
      final token = await _messaging.getToken();

      // 사용자 정보 저장
      await _firestore.setData(
        path: '${AppConstants.usersCollection}/${user.uid}',
        data: {
          'email': email,
          'name': name,
          'studentId': studentId,
          'role': role,
          'fcmToken': token,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      return userCredential;
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  // 이메일/비밀번호로 로그인
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('로그인 시도: $email');

      // Firebase Authentication으로 로그인
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        print('❌ 로그인 실패: 사용자 정보가 없습니다.');
        throw Exception('로그인에 실패했습니다.');
      }

      print('✅ 로그인 성공: ${user.uid}');

      // FCM 토큰 업데이트 시도
      try {
        final token = await _messaging.getToken();
        print('FCM 토큰: $token');

        await _firestore.updateData(
          path: '${AppConstants.usersCollection}/${user.uid}',
          data: {'fcmToken': token},
        );
        print('FCM 토큰 업데이트 완료');
      } catch (e) {
        print('⚠️ FCM 토큰 업데이트 실패 (무시됨): $e');
        // FCM 토큰 업데이트 실패는 로그인을 방해하지 않도록 무시
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase 인증 오류: ${e.code} - ${e.message}');
      String errorMessage = '로그인에 실패했습니다.';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = '등록되지 않은 이메일입니다.';
          break;
        case 'wrong-password':
          errorMessage = '비밀번호가 올바르지 않습니다.';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'user-disabled':
          errorMessage = '비활성화된 계정입니다.';
          break;
        case 'too-many-requests':
          errorMessage = '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('❌ 로그인 중 오류 발생: $e');
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // FCM 토큰 제거
        await _firestore.updateData(
          path: '${AppConstants.usersCollection}/${user.uid}',
          data: {'fcmToken': FieldValue.delete()},
        );
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('로그아웃에 실패했습니다: $e');
    }
  }

  // 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('비밀번호 재설정 이메일 전송에 실패했습니다: $e');
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserProfile({
    required String name,
    String? studentId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      final data = <String, dynamic>{'name': name};
      if (studentId != null) data['studentId'] = studentId;

      await _firestore.updateData(
        path: '${AppConstants.usersCollection}/${user.uid}',
        data: data,
      );
    } catch (e) {
      throw Exception('사용자 정보 업데이트에 실패했습니다: $e');
    }
  }

  // 사용자 삭제
  Future<void> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      // Firestore에서 사용자 데이터 삭제
      await _firestore
          .document('${AppConstants.usersCollection}/${user.uid}')
          .delete();

      // Firebase Auth에서 사용자 삭제
      await user.delete();
    } catch (e) {
      throw Exception('사용자 삭제에 실패했습니다: $e');
    }
  }

  // 사용자 역할 확인
  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final doc = await _firestore
        .document('${AppConstants.usersCollection}/${user.uid}')
        .get();
    if (!doc.exists) throw Exception('사용자 정보를 찾을 수 없습니다.');

    return doc.data()?['role'] as String? ?? AppConstants.roleStudent;
  }

  // 사용자 이름 가져오기
  Future<String> getUserName() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final doc = await _firestore
        .document('${AppConstants.usersCollection}/${user.uid}')
        .get();
    if (!doc.exists) throw Exception('사용자 정보를 찾을 수 없습니다.');

    return doc.data()?['name'] as String? ?? '';
  }

  // 사용자 학번 가져오기
  Future<String> getStudentId() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final doc = await _firestore
        .document('${AppConstants.usersCollection}/${user.uid}')
        .get();
    if (!doc.exists) throw Exception('사용자 정보를 찾을 수 없습니다.');

    return doc.data()?['studentId'] as String? ?? '';
  }

  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String phoneNumber,
    required String roomNumber,
  }) async {
    try {
      // Firebase Auth로 사용자 생성
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('사용자 생성에 실패했습니다.');
      }

      // Firestore에 사용자 정보 저장
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        studentId: studentId,
        phoneNumber: phoneNumber,
        dormRoom: roomNumber,
        role: AppConstants.roleStudent,
        languageCode: 'ko',
        notificationsEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } catch (e) {
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }
}
