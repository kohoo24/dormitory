import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';

import '../../core/widgets/circular_progress.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // UserModel과 currentSemesterId는 필요할 때 로드하도록 수정
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  // 대시보드 데이터 (실제 구현에서는 Firebase에서 가져와야 함)
  final Map<String, dynamic> _dashboardData = {
    'totalStudents': 120,
    'stayOutToday': 32,
    'notReturnedYesterday': 3,
    'occupancyRate': 0.85,
    'penaltyThisMonth': 24,
    'weeklyStayOutCounts': [18, 25, 32, 28, 22, 15, 12],
    'weeklyReturnRates': [0.95, 0.92, 0.98, 1.0, 0.96, 0.94, 0.97],
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // 실제 구현에서는 Firebase에서 사용자 정보 가져오기
      // 현재는 데이터를 직접 사용하므로 변수 저장 필요 없음
      // 실제 구현에서는 현재 학기 ID를 가져오는 로직 추가 필요
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text('관리자 대시보드'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 설정 화면으로 이동
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(0, '대시보드'),
                _buildTabButton(1, '외박 관리'),
                _buildTabButton(2, '출입 기록'),
                _buildTabButton(3, '벌점 관리'),
                _buildTabButton(4, '학기 설정'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: AppTheme.button.copyWith(
              color: isSelected ? Colors.white : AppTheme.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildStayRequestsTab();
      case 2:
        return _buildEntryLogsTab();
      case 3:
        return _buildPenaltiesTab();
      case 4:
        return _buildSemesterSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 16),
          _buildOccupancyCard(),
          const SizedBox(height: 16),
          _buildWeeklyStayOutChart(),
          const SizedBox(height: 16),
          _buildReturnRateChart(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 기숙사생',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dashboardData['totalStudents']}명',
                  style: AppTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 외박 인원',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dashboardData['stayOutToday']}명',
                  style: AppTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '미귀가 인원',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dashboardData['notReturnedYesterday']}명',
                  style: AppTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancyCard() {
    final occupancyRate = _dashboardData['occupancyRate'] as double;
    // uc810uc720uc728 ud37cuc13cud2b8 uacc4uc0b0uc744 ud558uc5ec uc9c1uc811 uc0acuc6a9

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기숙사 점유율',
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircularProgress(
                value: occupancyRate,
                size: 120,
                progressColor: AppTheme.primaryGreen,
                label: '점유율',
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOccupancyDetailItem(
                      '현재 인원',
                      '${(_dashboardData['totalStudents'] * occupancyRate).toInt()}명',
                      AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildOccupancyDetailItem(
                      '총 수용 인원',
                      '${_dashboardData['totalStudents']}명',
                      AppTheme.grey,
                    ),
                    const SizedBox(height: 12),
                    _buildOccupancyDetailItem(
                      '이번 달 벌점 발생',
                      '${_dashboardData['penaltyThisMonth']}건',
                      AppTheme.primaryRed,
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

  Widget _buildOccupancyDetailItem(String label, String value, Color color) {
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
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.body1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStayOutChart() {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final weeklyCounts = _dashboardData['weeklyStayOutCounts'] as List<int>;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주간 외박 현황',
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('yyyy년 MM월 dd일').format(DateTime.now().subtract(const Duration(days: 6)))} - ${DateFormat('yyyy년 MM월 dd일').format(DateTime.now())}',
            style: AppTheme.caption.copyWith(
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 40,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.8),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}명',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
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
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            weekDays[value.toInt()],
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.grey,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.grey,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppTheme.lightGrey,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(
                  weeklyCounts.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyCounts[index].toDouble(),
                        color: AppTheme.primaryBlue,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
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
  }

  Widget _buildReturnRateChart() {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final returnRates = _dashboardData['weeklyReturnRates'] as List<double>;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주간 귀가율',
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('yyyy년 MM월 dd일').format(DateTime.now().subtract(const Duration(days: 6)))} - ${DateFormat('yyyy년 MM월 dd일').format(DateTime.now())}',
            style: AppTheme.caption.copyWith(
              color: AppTheme.grey,
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
                  horizontalInterval: 0.1,
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
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            weekDays[value.toInt()],
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.grey,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value * 100).toInt()}%',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.grey,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: returnRates.length - 1.0,
                minY: 0.5,
                maxY: 1.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      returnRates.length,
                      (index) => FlSpot(index.toDouble(), returnRates[index]),
                    ),
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.3),
                          AppTheme.primaryGreen.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.8),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          '${(touchedSpot.y * 100).toInt()}%',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayRequestsTab() {
    // 실제 구현에서는 Firebase에서 데이터를 가져와야 함
    return const Center(child: Text('외박 관리 탭 - 구현 예정'));
  }

  Widget _buildEntryLogsTab() {
    // 실제 구현에서는 Firebase에서 데이터를 가져와야 함
    return const Center(child: Text('출입 기록 탭 - 구현 예정'));
  }

  Widget _buildPenaltiesTab() {
    // 실제 구현에서는 Firebase에서 데이터를 가져와야 함
    return const Center(child: Text('벌점 관리 탭 - 구현 예정'));
  }

  Widget _buildSemesterSettingsTab() {
    // 실제 구현에서는 Firebase에서 데이터를 가져와야 함
    return const Center(child: Text('학기 설정 탭 - 구현 예정'));
  }
}
