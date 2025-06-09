import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../constants/stay_request_constants.dart';

/// 외박 신청 화면의 테마를 관리하는 클래스입니다.
class StayRequestTheme {
  /// 시간 선택기의 테마를 반환합니다.
  static ThemeData getTimePickerTheme(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Theme.of(context).copyWith(
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: primaryColor),
        ),
        dayPeriodBorderSide: BorderSide(color: primaryColor),
        dayPeriodColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primaryColor
                : Colors.transparent),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : primaryColor),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
    );
  }

  /// 날짜 선택 컨테이너의 스타일을 반환합니다.
  static BoxDecoration getDateSelectionDecoration(bool isSelected) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(StayRequestConstants.cardBorderRadius),
      border: Border.all(
        color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
        width: isSelected ? 2.0 : 1.0,
      ),
    );
  }

  /// 시간 선택 컨테이너의 스타일을 반환합니다.
  static BoxDecoration getTimeSelectionDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(StayRequestConstants.cardBorderRadius),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  /// 라벨 컨테이너의 스타일을 반환합니다.
  static BoxDecoration getLabelDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// 제출 버튼의 스타일을 반환합니다.
  static ButtonStyle getSubmitButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(StayRequestConstants.cardBorderRadius),
      ),
      minimumSize: const Size.fromHeight(StayRequestConstants.buttonHeight),
    );
  }

  /// 취소 버튼의 스타일을 반환합니다.
  static ButtonStyle getCancelButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppTheme.primaryRed,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(StayRequestConstants.cardBorderRadius),
      ),
    );
  }

  /// 입력 필드의 장식을 반환합니다.
  static InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StayRequestConstants.cardBorderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StayRequestConstants.cardBorderRadius),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
