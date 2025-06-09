import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/penalty_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class PenaltyHistoryScreen extends StatefulWidget {
  const PenaltyHistoryScreen({super.key});

  @override
  State<PenaltyHistoryScreen> createState() => _PenaltyHistoryScreenState();
}

class _PenaltyHistoryScreenState extends State<PenaltyHistoryScreen> {
  UserModel? _user;
  String _currentSemesterId = '';
  bool _isLoading = true;
  List<PenaltyModel> _penalties = [];
  int _totalPoints = 0;

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
      // 실제 구현에서는 현재 학기 ID를 가져오는 로직 추가 필요
      const semesterId = 'current-semester-id';

      setState(() {
        _user = user;
        _currentSemesterId = semesterId;
        _isLoading = false;
      });

      // 벌점 내역 로드 (실제 구현에서는 Firebase에서 가져와야 함)
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
    final dummyPenalties = [
      PenaltyModel(
        id: '1',
        userId: _user?.id ?? '',
        userName: _user?.name ?? '',
        studentId: _user?.studentId ?? '',
        semesterId: _currentSemesterId,
        type: AppConstants.penaltyNoStayRequest,
        points: 3,
        reason: '외박 신청 없이 미귀가',
        date: now.subtract(const Duration(days: 10)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      PenaltyModel(
        id: '2',
        userId: _user?.id ?? '',
        userName: _user?.name ?? '',
        studentId: _user?.studentId ?? '',
        semesterId: _currentSemesterId,
        type: AppConstants.penaltyLateReturn,
        points: 2,
        reason: '외박 신청 기간보다 늦게 귀가',
        date: now.subtract(const Duration(days: 20)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      PenaltyModel(
        id: '3',
        userId: _user?.id ?? '',
        userName: _user?.name ?? '',
        studentId: _user?.studentId ?? '',
        semesterId: _currentSemesterId,
        type: AppConstants.penaltyNoCardTag,
        points: 1,
        reason: '카드키 미태깅',
        date: now.subtract(const Duration(days: 15)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      PenaltyModel(
        id: '4',
        userId: _user?.id ?? '',
        userName: _user?.name ?? '',
        studentId: _user?.studentId ?? '',
        semesterId: _currentSemesterId,
        type: AppConstants.penaltyOther,
        points: -2,
        reason: '벌점 감면 (봉사활동)',
        date: now.subtract(const Duration(days: 5)),
        adminId: 'admin-id',
        isAutomatic: false,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    int total = 0;
    for (final penalty in dummyPenalties) {
      total += penalty.points;
    }

    setState(() {
      _penalties = dummyPenalties;
      _totalPoints = total;
    });
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
        title: const Text('벌점 내역'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPenaltySummary(),
          Expanded(
            child:
                _penalties.isEmpty ? _buildEmptyState() : _buildPenaltyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltySummary() {
    final warningLevel =
        _totalPoints > 10 ? 'high' : (_totalPoints > 5 ? 'medium' : 'low');
    Color statusColor;
    String statusText;

    switch (warningLevel) {
      case 'high':
        statusColor = AppTheme.primaryRed;
        statusText = '경고: 벌점이 10점을 초과했습니다.';
        break;
      case 'medium':
        statusColor = Colors.orange;
        statusText = '주의: 벌점이 5점을 초과했습니다.';
        break;
      case 'low':
      default:
        statusColor = AppTheme.primaryGreen;
        statusText = '양호: 벌점이 5점 이하입니다.';
        break;
    }

    return CustomCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 학기 벌점 현황',
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_totalPoints',
                    style: AppTheme.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: AppTheme.body1.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '벌점 20점 이상 누적 시 기숙사 퇴소 조치됩니다.',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 16),
          Text(
            '벌점 내역이 없습니다.',
            style: AppTheme.body1.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '앞으로도 기숙사 규칙을 잘 지켜주세요!',
            style: AppTheme.caption.copyWith(
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _penalties.length,
      itemBuilder: (context, index) {
        final penalty = _penalties[index];
        return _buildPenaltyCard(penalty);
      },
    );
  }

  Widget _buildPenaltyCard(PenaltyModel penalty) {
    final isPositive = penalty.points < 0;
    final pointsText = isPositive ? '${penalty.points}' : '+${penalty.points}';
    final pointsColor =
        isPositive ? AppTheme.primaryGreen : AppTheme.primaryRed;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy년 MM월 dd일').format(penalty.date),
                style: AppTheme.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pointsColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pointsText,
                  style: AppTheme.caption.copyWith(
                    color: pointsColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            penalty.reason,
            style: AppTheme.body1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    penalty.isAutomatic
                        ? Icons.auto_awesome
                        : Icons.person_outline,
                    size: 16,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    penalty.isAutomatic ? '자동 부여' : '관리자 부여',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
              if (penalty.isAutomatic &&
                  DateTime.now().difference(penalty.date).inDays <= 3)
                TextButton(
                  onPressed: () {
                    // 이의 제기 기능 구현 (실제 구현에서는 Firebase와 연동)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이의 제기가 접수되었습니다.')),
                    );
                  },
                  child: Text(
                    '이의 제기',
                    style: AppTheme.button.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
