import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

/// 다른 앱 추천 섹션 — 매일 시리즈
class OtherAppsSection extends StatelessWidget {
  const OtherAppsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          _AppRecommendCard(
            icon: Icons.spa_outlined,
            name: '매일오라클',
            desc: '44장 오라클 카드',
            color: const Color(0xFFE8B4C8),
          ),
          const SizedBox(width: 12),
          _AppRecommendCard(
            icon: Icons.landscape_outlined,
            name: '매일룬',
            desc: '24개 룬 스톤',
            color: const Color(0xFFB4C8E8),
          ),
        ],
      ),
    );
  }
}

class _AppRecommendCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String desc;
  final Color color;

  const _AppRecommendCard({
    required this.icon,
    required this.name,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '준비 중',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
