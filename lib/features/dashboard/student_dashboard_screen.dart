import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../stay/screens/stay_request_screen.dart';
import '../notifications/notification_screen.dart';
import '../settings/settings_screen.dart';
import '../stay/screens/stay_request_history_screen.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../stay/models/stay_request.dart';
import '../../models/user_model.dart';
import '../stay/services/stay_request_service.dart';
import '../../services/firebase_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _user;
  String _currentSemesterId = '';
  bool _isLoading = true;
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // 날씨 정보
  String _weatherCondition = '맑음';
  int _temperature = 22;
  bool _isWeatherLoading = true;

  // 벌점 정보
  int _totalPenaltyPoints = 0;
  int _maxPenaltyPoints = 10;
  List<Map<String, dynamic>> _penaltyHistory = [];
  bool _isPenaltyLoading = true;

  // 외박 신청 정보
  List<StayRequest> _stayRequests = [];
  bool _isStayRequestLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
    _loadWeatherData();
    _loadPenaltyData();
    _loadStayRequests();

    // 애니메이션 효과를 위한 지연 로딩
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      debugPrint('사용자 ID: ${user.uid}');
      debugPrint('Firestore 경로: users/${user.uid}');

      // Firestore에서 사용자 정보 가져오기
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();

      debugPrint('Firestore 응답: ${userDoc.data()}');

      if (!userDoc.exists) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final userData = userDoc.data()!;
      userData['id'] = user.uid;

      debugPrint('파싱된 사용자 데이터: $userData');

      final currentUser = UserModel.fromJson(userData);

      if (mounted) {
        setState(() {
          _user = currentUser;
          _currentSemesterId = currentUser.currentSemesterId ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('사용자 정보를 불러오는 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터를 불러오는 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppTheme.primaryRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      final weatherSnapshot = await FirebaseService.database
          .ref()
          .child('public')
          .child('weather')
          .child('current')
          .get();

      if (weatherSnapshot.exists) {
        final weatherData =
            Map<String, dynamic>.from(weatherSnapshot.value as Map);
        if (mounted) {
          setState(() {
            _weatherCondition = weatherData['condition'] ?? '맑음';
            _temperature = weatherData['temperature'] ?? 22;
            _isWeatherLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('날씨 정보를 불러오는 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _isWeatherLoading = false;
        });
      }
    }
  }

  Future<void> _loadPenaltyData() async {
    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final penaltySnapshot = await FirebaseService.database
          .ref()
          .child('users')
          .child(user.uid)
          .child('penalties')
          .get();

      if (penaltySnapshot.exists) {
        final penaltyData =
            Map<String, dynamic>.from(penaltySnapshot.value as Map);
        final history =
            List<Map<String, dynamic>>.from(penaltyData['history'] ?? []);

        if (mounted) {
          setState(() {
            _totalPenaltyPoints = penaltyData['totalPoints'] ?? 0;
            _maxPenaltyPoints = penaltyData['maxPoints'] ?? 10;
            _penaltyHistory = history;
            _isPenaltyLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('벌점 정보를 불러오는 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _isPenaltyLoading = false;
        });
      }
    }
  }

  Future<void> _loadStayRequests() async {
    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final stayRequestService = StayRequestService();
      final requests = await stayRequestService.getStayHistory().first;

      if (mounted) {
        setState(() {
          _stayRequests = requests;
          _isStayRequestLoading = false;
        });
      }
    } catch (e) {
      debugPrint('외박 신청 정보를 불러오는 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _isStayRequestLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadUserData(),
      _loadWeatherData(),
      _loadPenaltyData(),
      _loadStayRequests(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.ultraLightGrey,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: AppTheme.primaryBlue,
        backgroundColor: Colors.white,
        onRefresh: _refreshData,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 100.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      _buildWeatherWidget()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      _buildQuickActions()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 300.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      _buildStayRequestsSection()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      _buildPenaltySummary()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar()
          .animate()
          .fadeIn(duration: 600.ms, delay: 600.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppTheme.ultraLightGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로딩 애니메이션
            SizedBox(
              width: 120,
              height: 120,
              child: Lottie.network(
                'https://assets2.lottiefiles.com/private_files/lf30_lndg7fhf.json',
                repeat: true,
                frameRate: FrameRate(60),
                errorBuilder: (context, error, stackTrace) =>
                    const CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 로딩 텍스트
            Shimmer.fromColors(
              baseColor: AppTheme.primaryBlue,
              highlightColor: AppTheme.secondaryBlue,
              child: Text(
                '데이터를 불러오는 중...',
                style: AppTheme.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          // 날씨 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _weatherCondition == '맑음'
                  ? Icons.wb_sunny_rounded
                  : Icons.cloud_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // 날씨 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 날씨',
                  style: AppTheme.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$_temperature°C',
                      style: AppTheme.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _weatherCondition,
                      style: AppTheme.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 날짜 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('E', 'ko_KR').format(DateTime.now()),
                style: AppTheme.body2.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                DateFormat('MM월 dd일').format(DateTime.now()),
                style: AppTheme.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 인사말과 사용자 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryBlueGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.lightShadow,
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_user?.name ?? ''} 님',
                    style: AppTheme.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 알림 및 프로필 아이콘
          Row(
            children: [
              // 알림 버튼
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.lightShadow,
                    ),
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.darkGrey,
                          size: 24,
                        ),
                        // 알림 배지
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 프로필 버튼
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryBlueGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.lightShadow,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStayRequestsSection() {
    if (_isStayRequestLoading) {
      return _buildLoadingShimmer();
    }

    final upcomingRequests = _stayRequests
        .where((request) =>
            request.status == AppConstants.statusApproved &&
            request.endDate.isAfter(DateTime.now()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '예정된 외박',
              style: AppTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // 전체보기 버튼
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StayRequestHistoryScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체보기',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 외박 리스트 또는 빈 상태
        if (upcomingRequests.isEmpty)
          _buildEmptyStayRequests()
        else
          _buildStayRequestsList(upcomingRequests),
      ],
    );
  }

  Widget _buildEmptyStayRequests() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 애니메이션 추가
          SizedBox(
            height: 120,
            width: 120,
            child: Lottie.asset(
              'assets/animations/empty_calendar.json',
              repeat: true,
              frameRate: FrameRate(60),
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.event_busy_rounded,
                size: 60,
                color: AppTheme.lightGrey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '예정된 외박이 없습니다',
            style: AppTheme.subtitle2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '외박 신청을 하시면 이곳에 표시됩니다',
            style: AppTheme.body2.copyWith(
              color: AppTheme.mediumGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 신청 버튼 개선
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StayRequestScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(200, 52),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  '외박 신청하기',
                  style: AppTheme.button,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayRequestsList(List<StayRequest> requests) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.lightShadow,
          ),
          child: Column(
            children: [
              // 상단 정보 영역
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 외박 아이콘
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getStatusIcon(request.status),
                        color: _getStatusColor(request.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 외박 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 외박 날짜
                              Text(
                                DateFormat('MM월 dd일 (E)', 'ko_KR')
                                    .format(request.startDate),
                                style: AppTheme.subtitle2.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // 상태 표시
                              _buildStatusChip(request.status),
                            ],
                          ),
                          if (request.startDate != request.endDate) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_right_alt_rounded,
                                  size: 16,
                                  color: AppTheme.mediumGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MM월 dd일 (E)', 'ko_KR')
                                      .format(request.endDate),
                                  style: AppTheme.body2.copyWith(
                                    color: AppTheme.mediumGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.tertiaryBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${request.endDate.difference(request.startDate).inDays + 1}일',
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          // 외박 사유
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.ultraLightGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: AppTheme.mediumGrey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    request.reason,
                                    style: AppTheme.body2.copyWith(
                                      color: AppTheme.darkGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 버튼 영역
              if (request.status == AppConstants.statusPending ||
                  request.status == AppConstants.statusApproved)
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.ultraLightGrey,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      onTap: () {
                        // 외박 신청 취소 로직
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              size: 18,
                              color: AppTheme.primaryRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '외박 신청 취소',
                              style: AppTheme.button.copyWith(
                                color: AppTheme.primaryRed,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return AppTheme.primaryGreen;
      case AppConstants.statusRejected:
        return AppTheme.primaryRed;
      case AppConstants.statusCancelled:
        return AppTheme.mediumGrey;
      case AppConstants.statusPending:
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return Icons.check_circle_outline_rounded;
      case AppConstants.statusRejected:
        return Icons.cancel_outlined;
      case AppConstants.statusCancelled:
        return Icons.not_interested_rounded;
      case AppConstants.statusPending:
      default:
        return Icons.schedule_rounded;
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case AppConstants.statusApproved:
        backgroundColor = AppTheme.primaryGreen.withOpacity(0.1);
        textColor = AppTheme.primaryGreen;
        text = '승인됨';
        break;
      case AppConstants.statusRejected:
        backgroundColor = AppTheme.primaryRed.withOpacity(0.1);
        textColor = AppTheme.primaryRed;
        text = '거절됨';
        break;
      case AppConstants.statusCancelled:
        backgroundColor = AppTheme.grey.withOpacity(0.1);
        textColor = AppTheme.grey;
        text = '취소됨';
        break;
      case AppConstants.statusPending:
      default:
        backgroundColor = AppTheme.primaryBlue.withOpacity(0.1);
        textColor = AppTheme.primaryBlue;
        text = '대기중';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.apps_rounded,
                size: 18,
                color: AppTheme.accentPurple,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '빠른 메뉴',
              style: AppTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 빠른 메뉴 그리드
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickActionItem(
                icon: Icons.add_circle_outline_rounded,
                label: '외박 신청',
                description: '',
                gradient: AppTheme.primaryBlueGradient,
                isMain: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StayRequestScreen()),
                  );
                },
              ),
              _buildQuickActionItem(
                icon: Icons.history_rounded,
                label: '외박 내역',
                description: '',
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentTeal,
                    AppTheme.accentTeal.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  // 외박 내역 화면으로 이동
                },
              ),
              _buildQuickActionItem(
                icon: Icons.warning_amber_rounded,
                label: '벌점 내역',
                description: '',
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryRed, AppTheme.secondaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  // 벌점 내역 화면으로 이동
                },
              ),
              _buildQuickActionItem(
                icon: Icons.notifications_rounded,
                label: '알림 확인',
                description: '',
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentYellow,
                    AppTheme.accentYellow.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  // 알림 화면으로 이동
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required String description,
    required Gradient gradient,
    bool isMain = false,
    required VoidCallback onTap,
  }) {
    // MediaQuery를 사용하여 화면 너비에 맞게 버튼 크기 조정
    final screenWidth = MediaQuery.of(context).size.width;
    // 패딩과 여백을 고려한 버튼 너비 계산 (4개의 버튼)
    final buttonWidth = (screenWidth - 60) / 4; // 60은 좌우 패딩과 버튼 간 간격

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: buttonWidth,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.lightShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // 라벨
                Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltySummary() {
    if (_isPenaltyLoading) {
      return _buildLoadingShimmer();
    }

    final remainingPoints = _maxPenaltyPoints - _totalPenaltyPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '벌점 요약',
              style: AppTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // 자세히 버튼
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  // 벌점 내역 화면으로 이동
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '자세히',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppTheme.primaryRed,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 벌점 요약 카드
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.lightShadow,
          ),
          child: Column(
            children: [
              // 상단 영역 - 벌점 정보
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 벌점 그래프 및 수치
                    Row(
                      children: [
                        // 벌점 그래프
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 배경 원
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: AppTheme.ultraLightGrey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 진행도 원
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value:
                                      _totalPenaltyPoints / _maxPenaltyPoints,
                                  strokeWidth: 12,
                                  backgroundColor: AppTheme.lightGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getPenaltyStatusColor(
                                        _totalPenaltyPoints, _maxPenaltyPoints),
                                  ),
                                ),
                              ),
                              // 벌점 수치
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_totalPenaltyPoints',
                                    style: AppTheme.h3.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getPenaltyStatusColor(
                                          _totalPenaltyPoints,
                                          _maxPenaltyPoints),
                                    ),
                                  ),
                                  Text(
                                    '/ $_maxPenaltyPoints',
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // 벌점 상태 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '현재 벌점 상태',
                                style: AppTheme.subtitle2.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 상태 배지
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getPenaltyStatusColor(
                                          _totalPenaltyPoints,
                                          _maxPenaltyPoints)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getPenaltyStatusText(
                                      _totalPenaltyPoints, _maxPenaltyPoints),
                                  style: AppTheme.caption.copyWith(
                                    color: _getPenaltyStatusColor(
                                        _totalPenaltyPoints, _maxPenaltyPoints),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 남은 벌점 정보
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 14,
                                    color: AppTheme.mediumGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '남은 벌점: ',
                                    style: AppTheme.body2.copyWith(
                                      color: AppTheme.mediumGrey,
                                    ),
                                  ),
                                  Text(
                                    '$remainingPoints점',
                                    style: AppTheme.body2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 구분선
              const Divider(height: 1),

              // 하단 영역 - 벌점 기록
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최근 벌점 기록',
                      style: AppTheme.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_penaltyHistory.isEmpty)
                      Center(
                        child: Text(
                          '벌점 기록이 없습니다',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _penaltyHistory
                            .take(3)
                            .map((penalty) => _buildPenaltyHistoryItem(
                                  date: DateFormat('MM/dd')
                                      .format(DateTime.parse(penalty['date'])),
                                  reason: penalty['reason'],
                                  points: penalty['points'],
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    // 경고 메시지
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppTheme.primaryRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '10점 이상 벌점 누적 시 기숙사 퇴사 조치될 수 있습니다.',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPenaltyStatusColor(int points, int maxPoints) {
    final percentage = points / maxPoints;
    if (percentage < 0.3) {
      return AppTheme.primaryGreen;
    } else if (percentage < 0.7) {
      return AppTheme.accentYellow;
    } else {
      return AppTheme.primaryRed;
    }
  }

  String _getPenaltyStatusText(int points, int maxPoints) {
    final percentage = points / maxPoints;
    if (percentage < 0.3) {
      return '양호';
    } else if (percentage < 0.7) {
      return '주의';
    } else {
      return '위험';
    }
  }

  Widget _buildPenaltyHistoryItem({
    required String date,
    required String reason,
    required int points,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ultraLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 및 벌점
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                date,
                style: AppTheme.caption.copyWith(
                  color: AppTheme.mediumGrey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$points점',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // 사유
          Expanded(
            child: Text(
              reason,
              style: AppTheme.body2.copyWith(
                color: AppTheme.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(0, Icons.home_outlined, Icons.home_rounded, '홈'),
            _buildNavBarItem(
                1, Icons.hotel_outlined, Icons.hotel_rounded, '외박'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = index == 0; // 현재는 홈 탭이 선택된 상태

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToScreen(index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryBlue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.mediumGrey.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.mediumGrey.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    if (index == 0) return; // 현재 화면이 이미 홈이면 아무것도 하지 않음

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StayRequestScreen()),
      );
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
