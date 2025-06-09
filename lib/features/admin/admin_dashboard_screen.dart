import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/entry_log_model.dart';
import '../../models/semester_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/semester_service.dart';
import '../stay/models/stay_request.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  UserModel? _user;
  SemesterModel? _currentSemester;
  bool _isLoading = true;

  // 통계 데이터
  int _totalStudents = 0;
  int _totalStayRequests = 0;
  int _pendingStayRequests = 0;
  int _totalPenalties = 0;

  // 차트 데이터
  List<FlSpot> _weeklyStayRequestsData = [];
  List<double> _penaltyTypeData = [];

  // 최근 외박 신청 및 출입 기록
  List<StayRequest> _recentStayRequests = [];
  List<EntryLogModel> _recentEntryLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 사용자 및 학기 정보 로드
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      final currentSemester = await SemesterService.getCurrentSemester();

      // 더미 데이터 로드 (실제 구현에서는 Firebase에서 가져와야 함)
      _loadDummyData();

      setState(() {
        _user = user;
        _currentSemester = currentSemester;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 에러 처리
    }
  }

  // 더미 데이터 로드 (실제 구현에서는 Firebase에서 가져와야 함)
  void _loadDummyData() {
    // 통계 데이터
    _totalStudents = 120;
    _totalStayRequests = 45;
    _pendingStayRequests = 8;
    _totalPenalties = 12;

    // 주간 외박 신청 데이터
    _weeklyStayRequestsData = [
      const FlSpot(0, 3),
      const FlSpot(1, 5),
      const FlSpot(2, 8),
      const FlSpot(3, 10),
      const FlSpot(4, 7),
      const FlSpot(5, 12),
      const FlSpot(6, 9),
    ];

    // 벌점 유형별 데이터
    _penaltyTypeData = [6, 4, 2]; // 무단외박, 카드키 미태깅, 기타

    // 최근 외박 신청
    final now = DateTime.now();
    _recentStayRequests = [
      StayRequest(
        id: '',
        userId: 'current_user_id',
        userName: '사용자 이름',
        studentId: '학번',
        dormRoom: '미배정',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 3)),
        reason: '외박',
        status: AppConstants.statusPending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      StayRequest(
        id: '',
        userId: 'current_user_id',
        userName: '사용자 이름',
        studentId: '학번',
        dormRoom: '미배정',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 3)),
        reason: '외박',
        status: AppConstants.statusApproved,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      StayRequest(
        id: '',
        userId: 'current_user_id',
        userName: '사용자 이름',
        studentId: '학번',
        dormRoom: '미배정',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 3)),
        reason: '외박',
        status: AppConstants.statusRejected,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // 최근 출입 기록
    _recentEntryLogs = [
      EntryLogModel(
        id: '1',
        userId: 'user1',
        userName: '김철수',
        studentId: '2020123456',
        semesterId: 'semester1',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: AppConstants.entryTypeEntry,
        isManualEntry: false,
        adminId: null,
        createdAt: now.subtract(const Duration(minutes: 30)),
        hasActiveStayRequest: false,
      ),
      EntryLogModel(
        id: '2',
        userId: 'user4',
        userName: '정민수',
        studentId: '2020654321',
        semesterId: 'semester1',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: AppConstants.entryTypeExit,
        isManualEntry: false,
        adminId: null,
        createdAt: now.subtract(const Duration(hours: 1)),
        hasActiveStayRequest: true,
      ),
      EntryLogModel(
        id: '3',
        userId: 'user5',
        userName: '한소희',
        studentId: '2021445566',
        semesterId: 'semester1',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: AppConstants.entryTypeEntry,
        isManualEntry: false,
        adminId: null,
        createdAt: now.subtract(const Duration(hours: 2)),
        hasActiveStayRequest: false,
      ),
    ];
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
        title: const Text('관리자 대시보드'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildWeeklyStayRequestsChart(),
            const SizedBox(height: 24),
            _buildPenaltyDistributionChart(),
            const SizedBox(height: 24),
            _buildRecentStayRequests(),
            const SizedBox(height: 24),
            _buildRecentEntryLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final currentTime = DateTime.now();
    String greeting;

    if (currentTime.hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (currentTime.hour < 18) {
      greeting = '좋은 오후에요';
    } else {
      greeting = '좋은 저녁이에요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${_user?.name ?? '관리자'}님',
          style: AppTheme.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentSemester?.name ?? '현재 학기'} 관리 대시보드',
          style: AppTheme.body1.copyWith(
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: '학생 수',
            value: _totalStudents.toString(),
            icon: Icons.people_outline,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '외박 신청',
            value: _totalStayRequests.toString(),
            subtitle: '대기 $_pendingStayRequests건',
            icon: Icons.hotel_outlined,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '벌점 발생',
            value: _totalPenalties.toString(),
            icon: Icons.warning_amber_outlined,
            color: AppTheme.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStayRequestsChart() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주간 외박 신청 현황',
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppTheme.lightGrey,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['월', '화', '수', '목', '금', '토', '일'];
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Text(
                            days[index],
                            style: AppTheme.caption,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTheme.caption,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 15,
                lineBarsData: [
                  LineChartBarData(
                    spots: _weeklyStayRequestsData,
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryBlue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyDistributionChart() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '벌점 유형별 분포',
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: _penaltyTypeData[0],
                    title: '${_penaltyTypeData[0].toInt()}건',
                    color: AppTheme.primaryRed,
                    radius: 80,
                    titleStyle: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: _penaltyTypeData[1],
                    title: '${_penaltyTypeData[1].toInt()}건',
                    color: AppTheme.primaryBlue,
                    radius: 80,
                    titleStyle: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: _penaltyTypeData[2],
                    title: '${_penaltyTypeData[2].toInt()}건',
                    color: AppTheme.primaryGreen,
                    radius: 80,
                    titleStyle: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('무단외박', AppTheme.primaryRed),
              const SizedBox(width: 24),
              _buildLegendItem('카드키 미태깅', AppTheme.primaryBlue),
              const SizedBox(width: 24),
              _buildLegendItem('기타', AppTheme.primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.caption,
        ),
      ],
    );
  }

  Widget _buildRecentStayRequests() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 외박 신청',
                style: AppTheme.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 외박 신청 관리 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('외박 신청 관리 화면으로 이동합니다.')),
                  );
                },
                child: Text(
                  '전체보기',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentStayRequests.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final request = _recentStayRequests[index];
              return _buildStayRequestItem(request);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStayRequestItem(StayRequest request) {
    Color statusColor;
    String statusText;

    switch (request.status) {
      case AppConstants.statusApproved:
        statusColor = AppTheme.primaryGreen;
        statusText = '승인됨';
        break;
      case AppConstants.statusRejected:
        statusColor = AppTheme.primaryRed;
        statusText = '거절됨';
        break;
      case AppConstants.statusPending:
      default:
        statusColor = AppTheme.primaryBlue;
        statusText = '대기중';
        break;
    }

    final dateFormat = DateFormat('MM/dd');
    final startDate = dateFormat.format(request.startDate);
    final endDate = dateFormat.format(request.endDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                request.userName.substring(0, 1),
                style: AppTheme.body1.copyWith(
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
                  '${request.userName} (${request.studentId})',
                  style: AppTheme.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$startDate - $endDate ($request.reason)',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusText,
              style: AppTheme.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntryLogs() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 출입 기록',
                style: AppTheme.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 출입 기록 관리 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('출입 기록 관리 화면으로 이동합니다.')),
                  );
                },
                child: Text(
                  '전체보기',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentEntryLogs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final log = _recentEntryLogs[index];
              return _buildEntryLogItem(log);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntryLogItem(EntryLogModel log) {
    final isEntry = log.type == AppConstants.entryTypeEntry;
    final iconColor = isEntry ? AppTheme.primaryGreen : AppTheme.primaryBlue;
    final icon = isEntry ? Icons.login : Icons.logout;
    final actionText = isEntry ? '입실' : '퇴실';

    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(log.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
                Text(
                  '${log.userName} (${log.studentId})',
                  style: AppTheme.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$formattedTime $actionText',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                      ),
                    ),
                    if (!log.hasActiveStayRequest &&
                        log.type == AppConstants.entryTypeExit)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '외박신청 없음',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryRed,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(log.timestamp),
            style: AppTheme.caption.copyWith(
              color: AppTheme.grey,
            ),
          ),
        ],
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
