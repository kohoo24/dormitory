import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/notification_model.dart';
import 'firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final Uuid _uuid = const Uuid();

  // FCM 토큰 가져오기
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // 알림 권한 요청
  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('알림 권한이 승인되었습니다.');
    } else {
      print('알림 권한이 거부되었습니다.');
    }
  }

  // 토큰 갱신 리스너
  void setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.updateData(
          path: 'users/${user.uid}',
          data: {'fcmToken': token},
        );
      }
    });
  }

  // 알림 설정
  Future<void> setupNotifications() async {
    await requestPermission();
    setupTokenRefreshListener();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('포그라운드 메시지 수신: ${message.notification?.title}');
      // TODO: 로컬 알림 표시
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // 알림 저장
  Future<void> saveNotification(NotificationModel notification) async {
    await _firestore.setData(
      path: 'notifications/${notification.id}',
      data: notification.toJson(),
    );
  }

  // 알림 목록 스트림
  Stream<List<NotificationModel>> getNotificationsStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');
    return _firestore.collectionStream<NotificationModel>(
      path: 'notifications',
      converter: (doc) =>
          NotificationModel.fromJson(doc.data() as Map<String, dynamic>),
      queryBuilder: (query) => query
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true),
    );
  }

  // 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    await _firestore.updateData(
      path: 'notifications/$notificationId',
      data: {'isRead': true},
    );
  }

  // 알림 전체 읽음 처리
  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.deleteData('notifications/$notificationId');
  }

  // 알림 전송 (Firestore에 저장 및 FCM 토큰 조회)
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // 사용자의 FCM 토큰 가져오기
    final userDoc = await _firestore.getDocument('users/$userId');
    if (!userDoc.exists) throw Exception('사용자를 찾을 수 없습니다.');
    final fcmToken = userDoc.data()?['fcmToken'] as String?;
    if (fcmToken == null) throw Exception('사용자의 FCM 토큰이 없습니다.');
    // Firestore에 알림 저장
    final notification = NotificationModel(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data ?? {},
      isRead: false,
      createdAt: DateTime.now(),
    );
    await _firestore.setData(
      path: 'notifications/${notification.id}',
      data: notification.toJson(),
    );
    // TODO: FCM 서버에 실제 알림 전송 로직 추가
  }

  // 리턴 리마인더 예약 (예시)
  Future<void> scheduleReturnReminder({
    required String userId,
    required String requestId,
    required DateTime returnDate,
  }) async {
    final String id = _uuid.v4();
    await _firestore.setData(
      path: 'scheduledNotifications/$id',
      data: {
        'userId': userId,
        'requestId': requestId,
        'type': AppConstants.notificationReturnReminder,
        'scheduledFor': returnDate,
        'processed': false,
        'createdAt': DateTime.now(),
      },
    );
  }
}

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드 메시지 수신: ${message.notification?.title}');
  // TODO: 백그라운드 알림 처리
}
