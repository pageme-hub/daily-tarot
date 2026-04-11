import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../app/routes.dart';

/// 설정 화면
///
/// - 알림 ON/OFF + 시간 설정
/// - 다크모드 선택 (시스템/라이트/다크)
/// - 다른 앱 추천
/// - 앱 정보 (버전, 개인정보처리방침, 이용약관)
/// - 면책 문구
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundDark
          : kBackgroundLight,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // ============ 알림 설정 ============
                _SectionHeader(title: '알림'),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('매일 타로 알림'),
                  subtitle: const Text('매일 아침 오늘의 카드를 알려드려요'),
                  value: settings.notificationEnabled,
                  activeColor: kPrimaryDark,
                  onChanged: (_) async {
                    // 알림을 켤 때: 권한 요청 후 스케줄 등록
                    if (!settings.notificationEnabled) {
                      final granted =
                          await NotificationService.instance
                              .requestAndroidPermission();
                      if (!granted) return;
                    }
                    // toggleNotification() 내부에서 스케줄 등록/취소 처리
                    await ref
                        .read(settingsProvider.notifier)
                        .toggleNotification();
                  },
                ),
                if (settings.notificationEnabled)
                  ListTile(
                    leading: const Icon(Icons.access_time_outlined),
                    title: const Text('알림 시간'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${settings.notificationHour.toString().padLeft(2, '0')}'
                          ':${settings.notificationMinute.toString().padLeft(2, '0')}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kPrimaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            size: 18, color: kTextSecondary),
                      ],
                    ),
                    onTap: () =>
                        _showTimePicker(context, ref, settings),
                  ),
                const Divider(height: 1),

                // ============ 디스플레이 ============
                _SectionHeader(title: '디스플레이'),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('다크 모드'),
                  subtitle: Text(_themeModeLabel(settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showThemePicker(context, ref, settings.themeMode),
                ),
                const Divider(height: 1),

                // ============ 다른 앱 추천 ============
                _SectionHeader(title: '매일 시리즈'),
                _OtherAppsSection(),
                const Divider(height: 1),

                // ============ 앱 정보 ============
                _SectionHeader(title: '앱 정보'),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('버전'),
                  trailing: Text(
                    AppConstants.appVersion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kTextSecondary,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('개인정보처리방침'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.privacy),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('이용약관'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.terms),
                ),
                const Divider(height: 1),

                // ============ 면책 문구 ============
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: kDefaultPadding,
                    vertical: 20,
                  ),
                  child: Text(
                    '본 앱은 엔터테인먼트 목적으로 제공됩니다.\n'
                    '타로 결과는 참고용이며 실제 결정의 근거로 사용하지 마세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: kTextSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ============ 디버그 전용 ===========
                if (kDebugMode) ...[
                  const Divider(height: 1),
                  _SectionHeader(title: '개발자 도구'),
                  _ScreenshotModeToggle(),
                ],
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  String _themeModeLabel(String mode) {
    return switch (mode) {
      'light' => '라이트',
      'dark' => '다크',
      _ => '시스템',
    };
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      ref
          .read(settingsProvider.notifier)
          .setNotificationTime(picked.hour, picked.minute);
    }
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    String currentMode,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '다크 모드 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final option in ['system', 'light', 'dark'])
                RadioListTile<String>(
                  title: Text(_themeModeToLabel(option)),
                  value: option,
                  groupValue: currentMode,
                  activeColor: kPrimaryDark,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(value);
                      ref
                          .read(settingsProvider.notifier)
                          .setThemeMode(value);
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _themeModeToLabel(String mode) {
    return switch (mode) {
      'light' => '라이트',
      'dark' => '다크',
      _ => '시스템',
    };
  }
}

/// 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: kPrimaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

/// 다른 앱 추천 섹션
class _OtherAppsSection extends StatelessWidget {
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

/// 스크린샷 모드 토글 — 디버그 전용, StatefulWidget 허용 (애니메이션 불필요)
class _ScreenshotModeToggle extends StatefulWidget {
  @override
  State<_ScreenshotModeToggle> createState() => _ScreenshotModeToggleState();
}

class _ScreenshotModeToggleState extends State<_ScreenshotModeToggle> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.camera_alt_outlined),
      title: const Text('스크린샷 모드'),
      subtitle: const Text('광고 전체 숨김 (디버그 전용)'),
      value: AppConstants.kScreenshotMode,
      activeColor: Colors.orange,
      onChanged: (value) {
        setState(() {
          AppConstants.kScreenshotMode = value;
        });
      },
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
