import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/stay_request.dart';
import '../services/stay_request_service.dart';

class StayRequestHistoryScreen extends StatelessWidget {
  const StayRequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = StayRequestService();

    return Scaffold(
      backgroundColor: AppTheme.ultraLightGrey,
      appBar: AppBar(
        title: const Text('외박 신청 내역'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<StayRequest>>(
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
                    size: 64,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: AppTheme.subtitle1.copyWith(
                      color: AppTheme.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                    textAlign: TextAlign.center,
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
          debugPrint('외박 신청 내역: ${requests.length}개');

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppTheme.mediumGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '외박 신청 내역이 없습니다',
                    style: AppTheme.subtitle1.copyWith(
                      color: AppTheme.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '외박 신청을 하시면 이곳에 표시됩니다',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              debugPrint('외박 신청 데이터: ${request.toJson()}');
              return _buildRequestCard(context, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, StayRequest request) {
    final now = DateTime.now();
    final isUpcoming = request.startDate.isAfter(now) &&
        (request.status == AppConstants.statusApproved ||
            request.status == AppConstants.statusPending);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                if (request.adminComment != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                          size: 16,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.adminComment!,
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (request.rejectionReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: AppTheme.primaryRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.rejectionReason!,
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUpcoming && request.status == AppConstants.statusPending)
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
                  onTap: () => _cancelRequest(context, request),
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

  Future<void> _cancelRequest(BuildContext context, StayRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('외박 신청 취소'),
        content: const Text('정말로 이 외박 신청을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = StayRequestService();
        await service.cancelStayRequest(request.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('외박 신청이 취소되었습니다.'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('외박 신청 취소 중 오류가 발생했습니다: $e'),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
      }
    }
  }
}
