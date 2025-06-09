import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/stay_request.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/firebase_service.dart';

class StayRequestService {
  static const _uuid = Uuid();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String _stayRequestsPath = 'stay_requests';
  final _auth = FirebaseService.auth;

  // 데이터베이스 연결 테스트
  Future<void> testDatabaseConnection() async {
    try {
      debugPrint('\n🔍 데이터베이스 연결 테스트 시작');

      // 데이터베이스 참조 생성
      final testRef = _database.child(_stayRequestsPath);

      // 데이터 읽기 시도
      final snapshot = await testRef.get();

      if (snapshot.exists) {
        debugPrint('\n✅ 데이터베이스 연결 성공');
        debugPrint('└─ 데이터: ${snapshot.value}');
      } else {
        debugPrint('\nℹ️ 데이터베이스 연결 성공 (데이터 없음)');
      }
    } catch (e) {
      debugPrint('\n❌ 데이터베이스 연결 실패');
      debugPrint('└─ 오류: $e');
    }
  }

  // 외박 신청 생성
  Future<StayRequest> createStayRequest(StayRequest request) async {
    try {
      final requestRef = _database.child(_stayRequestsPath).push();
      final requestWithId = request.copyWith(id: requestRef.key!);

      await requestRef.set(requestWithId.toJson());
      return requestWithId;
    } catch (e) {
      debugPrint('외박 신청 생성 중 오류 발생: $e');
      rethrow;
    }
  }

  // 외박 신청 제출
  Future<StayRequest> submitStayRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ 외박 신청 실패: 사용자가 로그인되어 있지 않습니다.');
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    try {
      debugPrint('\n📝 외박 신청 제출 시작');
      debugPrint('├─ 사용자 ID: ${user.uid}');
      debugPrint('├─ 시작일: $startDate');
      debugPrint('├─ 종료일: $endDate');
      debugPrint('└─ 사유: $reason');

      // Firestore에서 사용자 정보 가져오기
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('\n❌ 외박 신청 실패: 사용자 정보를 찾을 수 없습니다.');
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final userData = userDoc.data()!;
      debugPrint('\n📋 사용자 정보 조회 성공');
      debugPrint('├─ 이름: ${userData['name']}');
      debugPrint('├─ 학번: ${userData['studentId']}');
      debugPrint('└─ 방 번호: ${userData['dormRoom']}');

      final now = DateTime.now();
      final request = StayRequest(
        id: '', // ID는 createStayRequest에서 생성됨
        userId: user.uid,
        userName: userData['name'] as String,
        studentId: userData['studentId'] as String,
        dormRoom: userData['dormRoom'] as String? ?? '미배정',
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: AppConstants.statusPending,
        createdAt: now,
        updatedAt: now,
      );

      debugPrint('\n✅ 외박 신청 생성 성공');
      debugPrint('└─ 신청 데이터: ${request.toJson()}');

      return createStayRequest(request);
    } catch (e) {
      debugPrint('\n❌ 외박 신청 실패');
      debugPrint('└─ 오류: $e');
      rethrow;
    }
  }

  // 외박 신청 내역 조회
  Stream<List<StayRequest>> getStayHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    debugPrint('\n🔍 외박 신청 내역 조회 시작');
    debugPrint('└─ 사용자 ID: ${user.uid}');

    return _database
        .child(_stayRequestsPath)
        .orderByChild('userId')
        .equalTo(user.uid)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) {
        debugPrint('\nℹ️ 외박 신청 내역 없음');
        return [];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      debugPrint('\n📋 외박 신청 데이터 변환 시작');
      debugPrint('└─ 데이터 개수: ${data.length}');

      final requests = data.entries.map((entry) {
        final requestData = Map<String, dynamic>.from(entry.value as Map);
        requestData['id'] = entry.key;

        debugPrint('\n📝 외박 신청 데이터 처리:');
        debugPrint('├─ ID: ${entry.key}');
        debugPrint('├─ 시작일: ${requestData['startDate']}');
        debugPrint('├─ 종료일: ${requestData['endDate']}');
        debugPrint('└─ 상태: ${requestData['status']}');

        // null 값 처리
        requestData['userId'] = requestData['userId'] ?? '';
        requestData['userName'] = requestData['userName'] ?? '';
        requestData['studentId'] = requestData['studentId'] ?? '';
        requestData['dormRoom'] = requestData['dormRoom'] ?? '미배정';
        requestData['reason'] = requestData['reason'] ?? '';
        requestData['status'] =
            requestData['status'] ?? AppConstants.statusPending;
        requestData['adminComment'] = requestData['adminComment'];
        requestData['rejectionReason'] = requestData['rejectionReason'];

        // 날짜 처리
        try {
          requestData['startDate'] =
              requestData['startDate'] ?? DateTime.now().toIso8601String();
          requestData['endDate'] =
              requestData['endDate'] ?? DateTime.now().toIso8601String();
          requestData['createdAt'] =
              requestData['createdAt'] ?? DateTime.now().toIso8601String();
          requestData['updatedAt'] =
              requestData['updatedAt'] ?? DateTime.now().toIso8601String();
        } catch (e) {
          debugPrint('날짜 파싱 오류: $e');
          // 기본값 설정
          final now = DateTime.now().toIso8601String();
          requestData['startDate'] = now;
          requestData['endDate'] = now;
          requestData['createdAt'] = now;
          requestData['updatedAt'] = now;
        }

        try {
          final request = StayRequest.fromJson(requestData);
          debugPrint('✅ 외박 신청 데이터 변환 성공');
          return request;
        } catch (e) {
          debugPrint('❌ 외박 신청 데이터 변환 실패: $e');
          rethrow;
        }
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('\n✅ 외박 신청 내역 조회 완료');
      debugPrint('└─ 변환된 데이터 개수: ${requests.length}');
      return requests;
    });
  }

  // 외박 신청 취소
  Future<void> cancelStayRequest(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    final requestRef = _database.child(_stayRequestsPath).child(requestId);
    final snapshot = await requestRef.get();

    if (!snapshot.exists) {
      throw Exception('해당 외박 신청을 찾을 수 없습니다.');
    }

    final requestData = Map<String, dynamic>.from(snapshot.value as Map);
    if (requestData['userId'] != user.uid) {
      throw Exception('본인의 외박 신청만 취소할 수 있습니다.');
    }

    if (requestData['status'] != AppConstants.statusPending) {
      throw Exception('대기중인 외박 신청만 취소할 수 있습니다.');
    }

    await requestRef.update({
      'status': AppConstants.statusCancelled,
    });
  }

  // 외박 신청 상태 업데이트
  Future<void> updateStayRequestStatus({
    required String requestId,
    required String status,
    String? adminComment,
    String? rejectionReason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('\n❌ 외박 신청 상태 업데이트 실패');
      debugPrint('└─ 사용자가 로그인되어 있지 않습니다.');
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    try {
      debugPrint('\n🔄 외박 신청 상태 업데이트 시작');
      debugPrint('├─ 신청 ID: $requestId');
      debugPrint('├─ 변경할 상태: $status');
      debugPrint('└─ 사용자 ID: ${user.uid}');

      final snapshot =
          await _database.child(_stayRequestsPath).child(requestId).get();
      if (!snapshot.exists) {
        debugPrint('\n❌ 외박 신청 상태 업데이트 실패');
        debugPrint('└─ 존재하지 않는 외박 신청입니다.');
        throw Exception('존재하지 않는 외박 신청입니다.');
      }

      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (adminComment != null) {
        updates['adminComment'] = adminComment;
        debugPrint('├─ 관리자 코멘트 추가');
      }

      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
        debugPrint('├─ 거절 사유 추가');
      }

      await _database.child(_stayRequestsPath).child(requestId).update(updates);
      debugPrint('\n✅ 외박 신청 상태 업데이트 성공');
      debugPrint('└─ 신청 ID: $requestId');
    } catch (e) {
      debugPrint('\n❌ 외박 신청 상태 업데이트 실패');
      debugPrint('└─ 오류: $e');
      throw Exception('외박 신청 상태 업데이트에 실패했습니다.');
    }
  }

  // 외박 신청 상세 조회
  Future<StayRequest?> getStayRequest(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('\n❌ 외박 신청 상세 조회 실패');
      debugPrint('└─ 사용자가 로그인되어 있지 않습니다.');
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    try {
      debugPrint('\n📋 외박 신청 상세 조회 시작');
      debugPrint('├─ 신청 ID: $requestId');
      debugPrint('└─ 사용자 ID: ${user.uid}');

      final snapshot =
          await _database.child(_stayRequestsPath).child(requestId).get();
      if (!snapshot.exists) {
        debugPrint('\n❌ 외박 신청 상세 조회 실패');
        debugPrint('└─ 존재하지 않는 외박 신청입니다.');
        return null;
      }

      final request = StayRequest.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map));
      if (request.userId != user.uid) {
        debugPrint('\n❌ 외박 신청 상세 조회 실패');
        debugPrint('└─ 다른 사용자의 외박 신청은 조회할 수 없습니다.');
        return null;
      }

      debugPrint('\n✅ 외박 신청 상세 조회 성공');
      debugPrint('└─ 신청 데이터: ${request.toJson()}');
      return request;
    } catch (e) {
      debugPrint('\n❌ 외박 신청 상세 조회 실패');
      debugPrint('└─ 오류: $e');
      return null;
    }
  }
}
