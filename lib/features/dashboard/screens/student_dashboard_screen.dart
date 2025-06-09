import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../stay/models/stay_request.dart';
import '../../stay/services/stay_request_service.dart';
import '../../stay/screens/stay_request_screen.dart';
import '../../stay/screens/stay_request_history_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ultraLightGrey,
      appBar: AppBar(
        title: const Text('대시보드'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStayRequestSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStayRequestSection(BuildContext context) {
    final service = StayRequestService();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '외박 신청',
                style: AppTheme.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StayRequestHistoryScreen(),
                    ),
                  );
                },
                child: Text(
                  '전체보기',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.primaryBlue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<StayRequest>>(
            stream: service.getStayHistory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('외박 신청 내역 조회 오류: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 32,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '오류가 발생했습니다',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final requests = snapshot.data!;
              debugPrint('전체 외박 신청 수: ${requests.length}');

              final now = DateTime.now();
              debugPrint('현재 시간: $now');

              final upcomingRequests = requests.where((request) {
                debugPrint('\n외박 신청 데이터:');
                debugPrint('- 시작일: ${request.startDate}');
                debugPrint('- 종료일: ${request.endDate}');
                debugPrint('- 상태: ${request.status}');

                // 시작일이 현재 시간보다 이후이고, 상태가 승인됨 또는 대기중인 경우
                final isUpcoming = request.startDate.isAfter(now) &&
                    (request.status == AppConstants.statusApproved ||
                        request.status == AppConstants.statusPending);

                debugPrint('- isUpcoming: $isUpcoming');
                return isUpcoming;
              }).toList();

              debugPrint('\n예정된 외박 신청 수: ${upcomingRequests.length}');
              if (upcomingRequests.isNotEmpty) {
                debugPrint('첫 번째 예정된 외박:');
                debugPrint('- 시작일: ${upcomingRequests[0].startDate}');
                debugPrint('- 종료일: ${upcomingRequests[0].endDate}');
                debugPrint('- 상태: ${upcomingRequests[0].status}');
              }

              if (upcomingRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy_rounded,
                        size: 32,
                        color: AppTheme.mediumGrey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '예정된 외박이 없습니다',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('외박 신청하기'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: upcomingRequests.map((request) {
                  debugPrint('외박 신청 데이터 표시: ${request.toJson()}');
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.ultraLightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MM월 dd일 (E)', 'ko_KR')
                                  .format(request.startDate),
                              style: AppTheme.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                  '${request.durationInDays}일',
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
                        Text(
                          request.reason,
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.darkGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
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
}
