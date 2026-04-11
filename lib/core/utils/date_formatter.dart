// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:intl/intl.dart';

/// 날짜 포맷팅 유틸리티 클래스
///
/// 날짜와 시간을 다양한 형식으로 포맷팅하는 함수들을 제공합니다.
/// pubspec.yaml에 intl 패키지 추가 필요: intl: ^0.19.0
class DateFormatter {
  DateFormatter._(); // 인스턴스 생성 방지

  /// 날짜를 "yyyy-MM-dd" 형식으로 포맷팅
  ///
  /// 예: "2024-01-15"
  static String date(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 날짜를 "yyyy년 MM월 dd일" 형식으로 포맷팅
  ///
  /// 예: "2024년 1월 15일"
  static String dateKorean(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(date);
  }

  /// 날짜와 시간을 "yyyy-MM-dd HH:mm:ss" 형식으로 포맷팅
  ///
  /// 예: "2024-01-15 14:30:00"
  static String dateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// 시간을 "HH:mm" 형식으로 포맷팅
  ///
  /// 예: "14:30"
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// 상대 시간 표시 (예: "2시간 전", "3일 전")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// ISO 8601 형식으로 포맷팅
  ///
  /// 예: "2024-01-15T14:30:00.000Z"
  static String iso8601(DateTime date) {
    return date.toIso8601String();
  }
}
