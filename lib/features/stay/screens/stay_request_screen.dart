import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stay_request.dart';
import '../services/stay_request_service.dart';
import '../state/stay_request_state.dart';
import '../../../core/theme/app_theme.dart';

class StayRequestScreen extends StatelessWidget {
  const StayRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('외박 신청'),
      ),
      body: const StayRequestForm(),
    );
  }
}

class StayRequestForm extends StatefulWidget {
  const StayRequestForm({super.key});

  @override
  State<StayRequestForm> createState() => _StayRequestFormState();
}

class _StayRequestFormState extends State<StayRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = StayRequestService();
  final _state = StayRequestState();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 날짜 선택
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _state.startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      _state.updateStartDate(date);
                      _state.updateEndDate(date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _state.startDate == null
                        ? '날짜 선택'
                        : '${_state.startDate!.year}년 ${_state.startDate!.month}월 ${_state.startDate!.day}일',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 시간 선택
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _state.startTime ??
                          const TimeOfDay(hour: 19, minute: 0),
                    );
                    if (time != null) {
                      _state.updateStartTime(time);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _state.startTime == null
                        ? '시작 시간'
                        : '${_state.startTime!.hour.toString().padLeft(2, '0')}:${_state.startTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _state.endTime ??
                          const TimeOfDay(hour: 22, minute: 0),
                    );
                    if (time != null) {
                      _state.updateEndTime(time);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _state.endTime == null
                        ? '종료 시간'
                        : '${_state.endTime!.hour.toString().padLeft(2, '0')}:${_state.endTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 사유 입력
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '외박 사유',
              border: OutlineInputBorder(),
            ),
            onChanged: _state.updateReason,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                if (_state.startDate == null ||
                    _state.startTime == null ||
                    _state.endDate == null ||
                    _state.endTime == null ||
                    _state.reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 필드를 입력해주세요.'),
                      backgroundColor: AppTheme.primaryRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                  return;
                }

                final startDateTime = DateTime(
                  _state.startDate!.year,
                  _state.startDate!.month,
                  _state.startDate!.day,
                  _state.startTime!.hour,
                  _state.startTime!.minute,
                );

                final endDateTime = DateTime(
                  _state.endDate!.year,
                  _state.endDate!.month,
                  _state.endDate!.day,
                  _state.endTime!.hour,
                  _state.endTime!.minute,
                );

                try {
                  // StayRequestService를 사용하여 외박 신청 제출
                  await _service.submitStayRequest(
                    startDate: startDateTime,
                    endDate: endDateTime,
                    reason: _state.reason,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('외박 신청이 완료되었습니다.'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('외박 신청 중 오류가 발생했습니다: $e'),
                        backgroundColor: AppTheme.primaryRed,
                        behavior: SnackBarBehavior.floating,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('신청하기'),
          ),
        ],
      ),
    );
  }
}
