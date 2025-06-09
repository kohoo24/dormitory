import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/penalty_model.dart';
// import '../../models/user_model.dart'; // 사용하지 않는 import 제거
// import '../../services/auth_service.dart'; // 사용하지 않는 import 제거
// import '../../services/penalty_service.dart'; // 사용하지 않는 import 제거

class PenaltyManagementScreen extends StatefulWidget {
  const PenaltyManagementScreen({super.key});

  @override
  State<PenaltyManagementScreen> createState() => _PenaltyManagementScreenState();
}

class _PenaltyManagementScreenState extends State<PenaltyManagementScreen> {
  bool _isLoading = true;
  List<PenaltyModel> _penalties = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // final user = await AuthService.getCurrentUser(); // 사용하지 않는 변수 제거

      setState(() {
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
    final dummyPenalties = [
      PenaltyModel(
        id: '1',
        userId: 'user1',
        userName: '김철수',
        studentId: '2020123456',
        semesterId: 'semester1',
        type: AppConstants.penaltyNoStayRequest,
        points: 3,
        reason: '외박 신청 없이 미귀가',
        date: now.subtract(const Duration(days: 2)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      PenaltyModel(
        id: '2',
        userId: 'user2',
        userName: '이영희',
        studentId: '2019987654',
        semesterId: 'semester1',
        type: AppConstants.penaltyNoCardTag,
        points: 1,
        reason: '카드키 미태깅',
        date: now.subtract(const Duration(days: 3)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      PenaltyModel(
        id: '3',
        userId: 'user3',
        userName: '박지민',
        studentId: '2021112233',
        semesterId: 'semester1',
        type: AppConstants.penaltyOther,
        points: 2,
        reason: '소음 민원',
        date: now.subtract(const Duration(days: 5)),
        isAutomatic: false,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      PenaltyModel(
        id: '4',
        userId: 'user4',
        userName: '정민수',
        studentId: '2020654321',
        semesterId: 'semester1',
        type: AppConstants.penaltyNoStayRequest,
        points: 3,
        reason: '외박 신청 없이 미귀가',
        date: now.subtract(const Duration(days: 7)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusCanceled,
        cancelReason: '시스템 오류로 인한 취소',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      PenaltyModel(
        id: '5',
        userId: 'user5',
        userName: '한소희',
        studentId: '2021445566',
        semesterId: 'semester1',
        type: AppConstants.penaltyLateReturn,
        points: 2,
        reason: '외박 신청 기간보다 늦게 귀가',
        date: now.subtract(const Duration(days: 10)),
        isAutomatic: true,
        status: AppConstants.penaltyStatusActive,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    setState(() {
      _penalties = dummyPenalties;
    });
  }

  List<PenaltyModel> _getFilteredPenalties() {
    return _penalties.where((penalty) {
      return _searchQuery.isEmpty ||
          penalty.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          penalty.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          penalty.reason.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _addPenalty(String userId, String userName, String studentId, String type, int points, String reason) async {
    try {
      // 실제 구현에서는 Firebase에 추가
      // await PenaltyService.createPenalty(
      //   userId: userId,
      //   semesterId: 'semester1',
      //   type: type,
      //   points: points,
      //   reason: reason,
      //   date: DateTime.now(),
      //   isAutomatic: false,
      // );

      // 더미 데이터 추가
      final now = DateTime.now();
      final newPenalty = PenaltyModel(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        studentId: studentId,
        semesterId: 'semester1',
        type: type,
        points: points,
        reason: reason,
        date: now,
        isAutomatic: false,
        status: AppConstants.penaltyStatusActive,
        createdAt: now,
        updatedAt: now,
      );

      setState(() {
        _penalties.add(newPenalty);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('벌점이 추가되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _cancelPenalty(String penaltyId, String reason) async {
    try {
      // 실제 구현에서는 Firebase에서 업데이트
      // await PenaltyService.cancelPenalty(
      //   penaltyId: penaltyId,
      //   cancelReason: reason,
      // );

      // 더미 데이터 업데이트
      setState(() {
        _penalties = _penalties.map((penalty) {
          if (penalty.id == penaltyId) {
            final now = DateTime.now();
            return PenaltyModel(
              id: penalty.id,
              userId: penalty.userId,
              userName: penalty.userName,
              studentId: penalty.studentId,
              semesterId: penalty.semesterId,
              type: penalty.type,
              points: penalty.points,
              reason: penalty.reason,
              date: penalty.date,
              isAutomatic: penalty.isAutomatic,
              status: AppConstants.penaltyStatusCanceled,
              cancelReason: reason,
              createdAt: penalty.createdAt,
              updatedAt: now,
            );
          }
          return penalty;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('벌점이 취소되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  void _showAddPenaltyDialog() {
    final TextEditingController studentIdController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    String selectedType = AppConstants.penaltyOther;
    int selectedPoints = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('벌점 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: '학번',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('벌점 유형'),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(value: AppConstants.penaltyNoStayRequest, child: Text('외박 신청 없이 미귀가')),
                    DropdownMenuItem(value: AppConstants.penaltyNoCardTag, child: Text('카드키 미태깅')),
                    DropdownMenuItem(value: AppConstants.penaltyLateReturn, child: Text('외박 신청 기간보다 늦게 귀가')),
                    DropdownMenuItem(value: AppConstants.penaltyOther, child: Text('기타')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                        // 유형에 따라 기본 벌점 설정
                        if (value == AppConstants.penaltyNoStayRequest) {
                          selectedPoints = 3;
                        } else if (value == AppConstants.penaltyNoCardTag) {
                          selectedPoints = 1;
                        } else if (value == AppConstants.penaltyLateReturn) {
                          selectedPoints = 2;
                        } else {
                          selectedPoints = 2;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('벌점'),
                Slider(
                  value: selectedPoints.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: selectedPoints.toString(),
                  onChanged: (value) {
                    setState(() {
                      selectedPoints = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: '사유',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (studentIdController.text.trim().isNotEmpty &&
                    nameController.text.trim().isNotEmpty &&
                    reasonController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _addPenalty(
                    'user_${DateTime.now().millisecondsSinceEpoch}',
                    nameController.text.trim(),
                    studentIdController.text.trim(),
                    selectedType,
                    selectedPoints,
                    reasonController.text.trim(),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모든 필드를 입력해주세요.')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelPenaltyDialog(String penaltyId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('벌점 취소'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('취소 사유를 입력해주세요.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: '취소 사유',
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
                _cancelPenalty(penaltyId, reasonController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('취소 사유를 입력해주세요.')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryRed,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(PenaltyModel penalty) {
    // final dateFormat = DateFormat('yyyy년 MM월 dd일 HH:mm');
    // final formattedDate = dateFormat.format(penalty.date); // 사용하지 않는 변수 제거

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('벌점 상세 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('벌점 유형', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(penalty.type == AppConstants.penaltyNoStayRequest
                  ? '외박 신청 없이 미귀가'
                  : penalty.type == AppConstants.penaltyNoCardTag
                      ? '카드키 미태깅'
                      : penalty.type == AppConstants.penaltyLateReturn
                          ? '외박 신청 기간보다 늦게 귀가'
                          : '기타'),
            ),
            ListTile(
              title: const Text('벌점', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(penalty.points.toString()),
            ),
            ListTile(
              title: const Text('사유', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(penalty.reason),
            ),
            ListTile(
              title: const Text('자동 부과', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(penalty.isAutomatic ? '예' : '아니오'),
            ),
            ListTile(
              title: const Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(penalty.status == AppConstants.penaltyStatusActive ? '활성' : '취소됨'),
            ),
            if (penalty.status == AppConstants.penaltyStatusCanceled && penalty.cancelReason != null)
              ListTile(
                title: const Text('취소 사유', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(penalty.cancelReason!),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          if (penalty.status == AppConstants.penaltyStatusActive)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCancelPenaltyDialog(penalty.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryRed,
              ),
              child: const Text('벌점 취소'),
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

    final filteredPenalties = _getFilteredPenalties();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('벌점 관리'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPenaltyDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '학생 이름, 학번, 사유 검색',
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
            child: filteredPenalties.isEmpty
                ? _buildEmptyState()
                : _buildPenaltyList(filteredPenalties),
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
            Icons.warning_amber_outlined,
            size: 64,
            color: AppTheme.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '벌점 내역이 없습니다.',
            style: AppTheme.body1.copyWith(
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyList(List<PenaltyModel> penalties) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: penalties.length,
      itemBuilder: (context, index) {
        final penalty = penalties[index];
        return _buildPenaltyCard(penalty);
      },
    );
  }

  Widget _buildPenaltyCard(PenaltyModel penalty) {
    final dateFormat = DateFormat('MM/dd HH:mm');
    final formattedDate = dateFormat.format(penalty.date);

    Color statusColor;
    IconData icon;

    if (penalty.status == AppConstants.penaltyStatusCanceled) {
      statusColor = AppTheme.grey;
      icon = Icons.cancel_outlined;
    } else {
      switch (penalty.type) {
        case AppConstants.penaltyNoStayRequest:
          statusColor = AppTheme.primaryRed;
          icon = Icons.hotel_outlined;
          break;
        case AppConstants.penaltyNoCardTag:
          statusColor = AppTheme.primaryBlue;
          icon = Icons.credit_card_outlined;
          break;
        case AppConstants.penaltyLateReturn:
          statusColor = AppTheme.primaryGreen;
          icon = Icons.timer_outlined;
          break;
        case AppConstants.penaltyOther:
        default:
          statusColor = AppTheme.primaryGreen;
          icon = Icons.warning_amber_outlined;
          break;
      }
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showDetailDialog(penalty),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: statusColor,
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
                      penalty.userName,
                      style: AppTheme.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${penalty.points}점',
                            style: AppTheme.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (penalty.status == AppConstants.penaltyStatusCanceled)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '취소됨',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  penalty.studentId,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  penalty.reason,
                  style: AppTheme.body1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                      ),
                    ),
                    if (penalty.status == AppConstants.penaltyStatusActive)
                      TextButton(
                        onPressed: () => _showCancelPenaltyDialog(penalty.id),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppTheme.primaryRed,
                        ),
                        child: const Text('취소'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
