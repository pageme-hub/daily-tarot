import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/app_config_repository.dart';
import '../../../shared/constants/app_constants.dart';

// ==================== Repository Provider ====================

final appConfigRepositoryProvider = Provider<AppConfigRepository>(
  (ref) => AppConfigRepository(),
);

// ==================== 개인정보처리방침 URL Provider ====================

/// 개인정보처리방침 URL
///
/// Supabase → Hive 캐시 → 상수(kPrivacyPolicyUrl) 순서 fallback.
final privacyUrlProvider = FutureProvider<String>((ref) async {
  final repo = ref.read(appConfigRepositoryProvider);
  final url = await repo.fetchPrivacyUrl();
  return url ?? AppConstants.kPrivacyPolicyUrl;
});

// ==================== 이용약관 URL Provider ====================

/// 이용약관 URL
///
/// Supabase → Hive 캐시 → 상수(kTermsOfServiceUrl) 순서 fallback.
final termsUrlProvider = FutureProvider<String>((ref) async {
  final repo = ref.read(appConfigRepositoryProvider);
  final url = await repo.fetchTermsUrl();
  return url ?? AppConstants.kTermsOfServiceUrl;
});

// ==================== 활성 팝업 Provider ====================

/// 활성 팝업 목록
///
/// Supabase → Hive 캐시 → 빈 목록 순서 fallback.
final activePopupsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(appConfigRepositoryProvider);
  return repo.fetchActivePopups();
});
