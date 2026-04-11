import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/providers/settings_provider.dart';

/// 테마 모드 선택 바텀시트
class ThemePickerSheet extends StatelessWidget {
  final String currentMode;
  final WidgetRef ref;

  const ThemePickerSheet({
    super.key,
    required this.currentMode,
    required this.ref,
  });

  String _label(String mode) {
    return switch (mode) {
      'light' => '라이트',
      'dark' => '다크',
      _ => '시스템',
    };
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text(_label(option)),
              value: option,
              groupValue: currentMode,
              activeColor: kPrimaryDark,
              onChanged: (value) {
                if (value != null) {
                  // SettingsNotifier만 사용 — ThemeModeNotifier 이중관리 제거
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
