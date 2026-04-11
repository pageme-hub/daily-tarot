import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../app/routes.dart';
import '../widgets/other_apps_section.dart';
import '../widgets/theme_picker_sheet.dart';

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
                const _SectionHeader(title: '알림'),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('매일 타로 알림'),
                  subtitle: const Text('매일 아침 오늘의 카드를 알려드려요'),
                  value: settings.notificationEnabled,
                  activeColor: kPrimaryDark,
                  onChanged: (_) async {
                    if (!settings.notificationEnabled) {
                      final granted =
                          await NotificationService.instance
                              .requestAndroidPermission();
                      if (!granted) return;
                    }
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
                    onTap: () => _showTimePicker(context, ref, settings),
                  ),
                const Divider(height: 1),

                // ============ 디스플레이 ============
                const _SectionHeader(title: '디스플레이'),
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
                const _SectionHeader(title: '매일 시리즈'),
                const OtherAppsSection(),
                const Divider(height: 1),

                // ============ 앱 정보 ============
                const _SectionHeader(title: '앱 정보'),
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
                  const _SectionHeader(title: '개발자 도구'),
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
    // [피드백 2-1] 한국어 텍스트, [피드백 2-2] 12시간(오전/오후) 형식
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
      helpText: '알림 시간 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
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
      builder: (ctx) => ThemePickerSheet(
        currentMode: currentMode,
        ref: ref,
      ),
    );
  }
}

// ==================== 섹션 헤더 ====================

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

// ==================== 스크린샷 모드 토글 (디버그 전용) ====================

/// 스크린샷 모드 토글 — 디버그 전용
/// StatefulWidget 허용: 외부 상태 없이 UI 토글만 필요
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
