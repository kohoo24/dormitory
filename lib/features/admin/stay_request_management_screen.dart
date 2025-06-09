import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../stay/models/stay_request.dart';
// import '../../models/user_model.dart'; // 사용하지 않는 import 제거
// import '../../services/auth_service.dart'; // 사용하지 않는 import 제거
// import '../../services/stay_request_service.dart'; // 사용하지 않는 import 제거

class StayRequestManagementScreen extends StatefulWidget {
  const StayRequestManagementScreen({super.key});

  @override
  State<StayRequestManagementScreen> createState() =>
      _StayRequestManagementScreenState();
}

class _StayRequestManagementScreenState
    extends State<StayRequestManagementScreen>
    with SingleTickerProviderStateMixin {
  // UserModel? _user; // 사용하지 않는 변수 제거
  bool _isLoading = true;
  List<StayRequest> _stayRequests = [];
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // final user = await AuthService.getCurrentUser(); // 사용하지 않는 변수 제거

      setState(() {
        // _user = user; // 사용하지 않는 변수 제거
        _isLoading = false;
      });

      // 더미 데이터 로드 (실제 구현에서는 Firebase에서 가져와야 함)
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
    final dummyRequests = [
      StayRequest(
        id: '1',
        userId: 'user1',
        userName: '김철수',
        studentId: '2020123456',
        dormRoom: '미배정',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 3)),
        reason: '가족 행사',
        status: AppConstants.statusPending,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      StayRequest(
        id: '2',
        userId: 'user2',
        userName: '이영희',
        studentId: '2019987654',
        dormRoom: '미배정',
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 4)),
        reason: '친구 결혼식',
        status: AppConstants.statusApproved,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      StayRequest(
        id: '3',
        userId: 'user3',
        userName: '박지민',
        studentId: '2021112233',
        dormRoom: '미배정',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 5)),
        reason: '인턴십 면접',
        status: AppConstants.statusPending,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      StayRequest(
        id: '4',
        userId: 'user4',
        userName: '정민수',
        studentId: '2020654321',
        dormRoom: '미배정',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 6)),
        reason: '가족 방문',
        status: AppConstants.statusRejected,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        rejectionReason: '기간이 너무 짧습니다.',
      ),
      StayRequest(
        id: '5',
        userId: 'user5',
        userName: '한소희',
        studentId: '2021445566',
        dormRoom: '미배정',
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 9)),
        reason: '학술대회 참석',
        status: AppConstants.statusApproved,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      StayRequest(
        id: '6',
        userId: 'user6',
        userName: '최준호',
        studentId: '2022334455',
        dormRoom: '미배정',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 12)),
        reason: '취업 면접',
        status: AppConstants.statusPending,
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    setState(() {
      _stayRequests = dummyRequests;
    });
  }

  List<StayRequest> _getFilteredRequests() {
    String status;
    switch (_tabController.index) {
      case 0:
        status = AppConstants.statusPending;
        break;
      case 1:
        status = AppConstants.statusApproved;
        break;
      case 2:
        status = AppConstants.statusRejected;
        break;
      default:
        status = AppConstants.statusPending;
    }

    return _stayRequests.where((request) {
      final matchesStatus = request.status == status;
      final matchesSearch = _searchQuery.isEmpty ||
          request.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request.studentId
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          request.dormRoom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request.reason.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> _approveRequest(String requestId) async {
    try {
      // 실제 구현에서는 Firebase에서 업데이트
      // await StayRequestService.updateStayRequestStatus(
      //   requestId: requestId,
      //   status: AppConstants.statusApproved,
      // );

      // 더미 데이터 업데이트
      setState(() {
        _stayRequests = _stayRequests.map((request) {
          if (request.id == requestId) {
            return StayRequest(
              id: request.id,
              userId: request.userId,
              userName: request.userName,
              studentId: request.studentId,
              dormRoom: request.dormRoom,
              startDate: request.startDate,
              endDate: request.endDate,
              reason: request.reason,
              status: AppConstants.statusApproved,
              createdAt: request.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return request;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('외박 신청이 승인되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _rejectRequest(String requestId, String reason) async {
    try {
      // 실제 구현에서는 Firebase에서 업데이트
      // await StayRequestService.updateStayRequestStatus(
      //   requestId: requestId,
      //   status: AppConstants.statusRejected,
      //   rejectionReason: reason,
      // );

      // 더미 데이터 업데이트
      setState(() {
        _stayRequests = _stayRequests.map((request) {
          if (request.id == requestId) {
            return StayRequest(
              id: request.id,
              userId: request.userId,
              userName: request.userName,
              studentId: request.studentId,
              dormRoom: request.dormRoom,
              startDate: request.startDate,
              endDate: request.endDate,
              reason: request.reason,
              status: AppConstants.statusRejected,
              createdAt: request.createdAt,
              updatedAt: DateTime.now(),
              rejectionReason: reason,
            );
          }
          return request;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('외박 신청이 거절되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  void _showRejectDialog(String requestId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('외박 신청 거절'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('거절 사유를 입력해주세요.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: '거절 사유',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _rejectRequest(requestId, reasonController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('거절 사유를 입력해주세요.')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryRed,
            ),
            child: const Text('거절'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(StayRequest request) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일 HH:mm');
    final startDateStr = dateFormat.format(request.startDate);
    final endDateStr = dateFormat.format(request.endDate);
    final createdAtStr = dateFormat.format(request.createdAt);
    final updatedAtStr = dateFormat.format(request.updatedAt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('외박 신청 상세 정보'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('학생 이름', request.userName),
              _buildDetailItem('학번', request.studentId),
              _buildDetailItem('학교', request.dormRoom),
              _buildDetailItem('신청 일시', createdAtStr),
              _buildDetailItem('외박 기간', '$startDateStr ~ $endDateStr'),
              _buildDetailItem('외박 사유', request.reason),
              if (request.status == AppConstants.statusRejected &&
                  request.rejectionReason != null)
                _buildDetailItem('거절 사유', request.rejectionReason!),
              _buildDetailItem('업데이트 일시', updatedAtStr),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          if (request.status == AppConstants.statusPending) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRejectDialog(request.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryRed,
              ),
              child: const Text('거절'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _approveRequest(request.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('승인'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.body1,
          ),
        ],
      ),
    );
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

    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('외박 신청 관리'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.grey,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(text: '대기중'),
            Tab(text: '승인됨'),
            Tab(text: '거절됨'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '학생 이름, 학번, 학교, 사유 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredRequests.isEmpty
                ? _buildEmptyState()
                : _buildRequestList(filteredRequests),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_tabController.index) {
      case 0:
        message = '대기 중인 외박 신청이 없습니다.';
        break;
      case 1:
        message = '승인된 외박 신청이 없습니다.';
        break;
      case 2:
        message = '거절된 외박 신청이 없습니다.';
        break;
      default:
        message = '외박 신청이 없습니다.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hotel_outlined,
            size: 64,
            color: AppTheme.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.body1.copyWith(
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<StayRequest> requests) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(StayRequest request) {
    final dateFormat = DateFormat('MM/dd');
    final startDate = dateFormat.format(request.startDate);
    final endDate = dateFormat.format(request.endDate);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showDetailDialog(request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    request.userName.substring(0, 1),
                    style: AppTheme.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
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
                      request.userName,
                      style: AppTheme.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      request.studentId,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(request.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '외박 기간',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$startDate ~ $endDate',
                      style: AppTheme.body1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신청 사유',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.reason,
                      style: AppTheme.body1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.status == AppConstants.statusPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(request.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryRed,
                      side: const BorderSide(color: AppTheme.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRequest(request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('승인'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case AppConstants.statusApproved:
        color = AppTheme.primaryGreen;
        text = '승인됨';
        break;
      case AppConstants.statusRejected:
        color = AppTheme.primaryRed;
        text = '거절됨';
        break;
      case AppConstants.statusPending:
      default:
        color = AppTheme.primaryBlue;
        text = '대기중';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
