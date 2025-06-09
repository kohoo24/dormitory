import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  UserModel? _user;
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();

      setState(() {
        _user = user;
        _isLoading = false;
      });

      // 알림 로드 (실제 구현에서는 Firebase에서 가져와야 함)
      _loadDummyData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 에러 처리
    }
  }

  // 더미 데이터 로드 (실제 구현에서는 Firebase에서 가져와야 함)
  void _loadDummyData() {
    final now = DateTime.now();
    final dummyNotifications = [
      NotificationModel(
        id: '1',
        userId: _user?.id ?? '',
        type: AppConstants.notificationStayRequestApproved,
        title: '외박 신청 승인',
        body: '4월 25일~26일 외박 신청이 승인되었습니다.',
        data: {
          'requestId': 'request-1',
          'status': AppConstants.statusApproved,
        },
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: '2',
        userId: _user?.id ?? '',
        type: AppConstants.notificationReturnReminder,
        title: '귀가 알림',
        body: '내일이 외박 종료일입니다. 기숙사로 귀가하는 것을 잊지 마세요.',
        data: {
          'requestId': 'request-1',
        },
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: '3',
        userId: _user?.id ?? '',
        type: AppConstants.notificationPenaltyIssued,
        title: '벌점 부과',
        body: '카드키 미태깅으로 벌점 1점이 부과되었습니다.',
        data: {
          'penaltyId': 'penalty-1',
          'points': 1,
          'type': AppConstants.penaltyNoCardTag,
        },
        isRead: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '4',
        userId: _user?.id ?? '',
        type: AppConstants.notificationStayRequestRejected,
        title: '외박 신청 거절',
        body: '4월 30일~5월 2일 외박 신청이 거절되었습니다. 사유: 기간이 너무 깁니다.',
        data: {
          'requestId': 'request-2',
          'status': AppConstants.statusRejected,
        },
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    setState(() {
      _notifications = dummyNotifications;
    });
  }

  Future<void> _markAllAsRead() async {
    try {
      // uc2e4uc81c uad6cud604uc5d0uc11cub294 Firebaseuc5d0uc11c uc77duc74c ucc98ub9ac
      // await NotificationService.markAllNotificationsAsRead(_user!.id);

      // ub354ubbf8 ub370uc774ud130 ucc98ub9ac
      setState(() {
        _notifications = _notifications.map((notification) {
          return NotificationModel(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'ubaa8ub4e0 uc54cub9bcuc744 uc77duc74c ucc98ub9acud588uc2b5ub2c8ub2e4.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('uc624ub958uac00 ubc1cuc0ddud588uc2b5ub2c8ub2e4: $e')),
      );
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      // uc2e4uc81c uad6cud604uc5d0uc11cub294 Firebaseuc5d0uc11c uc77duc74c ucc98ub9ac
      // await NotificationService.markNotificationAsRead(notificationId);

      // ub354ubbf8 ub370uc774ud130 ucc98ub9ac
      setState(() {
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return NotificationModel(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              title: notification.title,
              body: notification.body,
              data: notification.data,
              isRead: true,
              createdAt: notification.createdAt,
            );
          }
          return notification;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('uc624ub958uac00 ubc1cuc0ddud588uc2b5ub2c8ub2e4: $e')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      // uc2e4uc81c uad6cud604uc5d0uc11cub294 Firebaseuc5d0uc11c uc0aduc81c ucc98ub9ac
      // await NotificationService.deleteNotification(notificationId);

      // ub354ubbf8 ub370uc774ud130 ucc98ub9ac
      setState(() {
        _notifications = _notifications
            .where((notification) => notification.id != notificationId)
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('uc54cub9bcuc774 uc0aduc81cub418uc5c8uc2b5ub2c8ub2e4.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('uc624ub958uac00 ubc1cuc0ddud588uc2b5ub2c8ub2e4: $e')),
      );
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // 알림 읽음 처리
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // 알림 타입에 따라 적절한 화면으로 이동
    switch (notification.type) {
      case AppConstants.notificationStayRequestApproved:
      case AppConstants.notificationStayRequestRejected:
        // 외박 내역 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('외박 내역 화면으로 이동합니다.')),
        );
        break;
      case AppConstants.notificationPenaltyIssued:
        // 벌점 내역 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('벌점 내역 화면으로 이동합니다.')),
        );
        break;
      case AppConstants.notificationReturnReminder:
        // 외박 내역 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('외박 내역 화면으로 이동합니다.')),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.any((notification) => !notification.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                '모두 읽음',
                style: AppTheme.button.copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppTheme.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '알림이 없습니다.',
            style: AppTheme.body1.copyWith(
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    // uc54cub9bc ud0c0uc785uc5d0 ub530ub77c uc544uc774ucf58 ubc0f uc0c9uc0c1 uc124uc815
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case AppConstants.notificationStayRequestApproved:
        icon = Icons.check_circle_outline;
        iconColor = AppTheme.primaryGreen;
        break;
      case AppConstants.notificationStayRequestRejected:
        icon = Icons.cancel_outlined;
        iconColor = AppTheme.primaryRed;
        break;
      case AppConstants.notificationPenaltyIssued:
        icon = Icons.warning_amber_outlined;
        iconColor = AppTheme.primaryRed;
        break;
      case AppConstants.notificationReturnReminder:
        icon = Icons.access_time;
        iconColor = AppTheme.primaryBlue;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppTheme.primaryBlue;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: AppTheme.primaryRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 16),
        backgroundColor: notification.isRead
            ? Colors.white
            : AppTheme.primaryBlue.withOpacity(0.05),
        onTap: () => _handleNotificationTap(notification),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: AppTheme.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTheme.body1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTimeAgo(notification.createdAt),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
