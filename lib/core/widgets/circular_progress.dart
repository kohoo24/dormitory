import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CircularProgress extends StatelessWidget {
  final double value; // 0.0 ~ 1.0 사이의 값
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Widget? centerWidget;
  final String? label;
  final TextStyle? labelStyle;

  const CircularProgress({
    super.key,
    required this.value,
    this.size = 200,
    this.strokeWidth = 15,
    this.progressColor = AppTheme.primaryBlue,
    this.backgroundColor = Colors.white,
    this.centerWidget,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          // 프로그레스 원
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                value: value,
                strokeWidth: strokeWidth,
                progressColor: progressColor,
                backgroundColor: backgroundColor.withOpacity(0.2),
              ),
            ),
          ),
          // 중앙 위젯
          if (centerWidget != null) centerWidget!,
          // 중앙 텍스트가 없는 경우 기본 퍼센트 표시
          if (centerWidget == null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: size / 5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                if (label != null) ...[  
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    style: labelStyle ?? 
                      TextStyle(
                        fontSize: size / 12,
                        color: AppTheme.grey,
                      ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원 그리기
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 프로그레스 원 그리기
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      progressRect,
      -pi / 2, // 시작 각도 (12시 방향)
      2 * pi * value, // 진행 각도
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
