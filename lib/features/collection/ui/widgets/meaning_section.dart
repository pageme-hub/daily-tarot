import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

/// 카드 의미 섹션 (정방향 / 역방향)
///
/// 카드 상세 화면에서 사용되는 의미 표시 위젯.
class MeaningSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String meaning;
  final Color accentColor;

  const MeaningSection({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.meaning,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 방향 제목
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 한 줄 메시지
          Text(
            '"$message"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 상세 의미
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.7,
                  color: kTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
