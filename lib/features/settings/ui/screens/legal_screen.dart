import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../providers/app_config_provider.dart';

/// 법적 요건 화면 (개인정보처리방침 / 이용약관)
///
/// Supabase에서 URL 로드 시도 → 실패 시 인앱 텍스트 표시.
enum LegalType { privacy, terms }

class LegalScreen extends ConsumerWidget {
  final LegalType type;

  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == LegalType.privacy ? '개인정보처리방침' : '이용약관';

    // Supabase에서 URL 로드 (Supabase 미연결 시 null)
    final urlAsync = type == LegalType.privacy
        ? ref.watch(privacyUrlProvider)
        : ref.watch(termsUrlProvider);

    final fallbackContent =
        type == LegalType.privacy ? _kPrivacyContent : _kTermsContent;

    // URL이 기본값 상수가 아닌 실제 URL이면 웹뷰로 열 수 있지만
    // 현재 webview 패키지 미포함 → 인앱 텍스트 표시
    // TODO: v1.1에서 url_launcher 또는 webview_flutter 추가
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: urlAsync.when(
          data: (url) {
            // URL이 기본 상수 URL이거나 비어있으면 인앱 텍스트 표시
            final isDefaultUrl = url == AppConstants.kPrivacyPolicyUrl ||
                url == AppConstants.kTermsOfServiceUrl;
            return Text(
              isDefaultUrl
                  ? fallbackContent
                  : '${fallbackContent}\n\n[온라인 버전: $url]',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.7,
                  ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(
            fallbackContent,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                ),
          ),
        ),
      ),
    );
  }
}

// ==================== 법적 텍스트 ====================

const String _kPrivacyContent = '''
개인정보처리방침

시행일: 2026년 4월 10일

앱팩토리(이하 "회사")는 「개인정보 보호법」에 따라 이용자의 개인정보를 보호하고 관련 고충을 신속하게 처리할 수 있도록 다음과 같이 개인정보처리방침을 수립·공개합니다.

1. 수집하는 개인정보

회사는 매일타로 앱 서비스 제공을 위해 아래와 같이 개인정보를 처리합니다.

• 수집 항목: 광고 식별자(ADID/IDFA), 앱 사용 로그(비식별)
• 수집 방법: 앱 사용 중 자동 수집
• 수집 목적: 광고 제공, 서비스 개선

2. 개인정보의 처리 및 보유 기간

회사는 법령에 따른 개인정보 보유·이용기간 또는 정보 주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

• 앱 사용 로그: 서비스 이용 기간 동안

3. 개인정보의 제3자 제공

회사는 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. 다만, 광고 서비스 제공을 위해 Google AdMob에 광고 식별자가 제공될 수 있습니다.

4. 개인정보 처리의 위탁

• Google LLC (광고 서비스, Firebase 분석)

5. 이용자 권리

이용자는 언제든지 개인정보 삭제를 요청할 수 있습니다. 앱 삭제 시 기기에 저장된 모든 데이터가 삭제됩니다.

6. 개인정보 보호 책임자

• 이메일: support@appfactory.kr

7. 개정 이력

본 방침은 2026년 4월 10일부터 적용됩니다.
''';

const String _kTermsContent = '''
이용약관

시행일: 2026년 4월 10일

제1조 (목적)

이 약관은 앱팩토리(이하 "회사")가 제공하는 매일타로 서비스(이하 "서비스")의 이용조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.

제2조 (서비스의 내용)

• 타로 카드 기반 일일 메시지 서비스
• 카드 도감 및 뽑기 이력 조회 기능
• 카드 이미지 저장 및 공유 기능

제3조 (면책 조항)

① 본 서비스는 엔터테인먼트 목적으로만 제공됩니다.
② 타로 카드 해석 결과는 참고용이며, 실제 의사결정의 근거로 사용할 수 없습니다.
③ 회사는 서비스 이용으로 인한 손해에 대해 책임을 지지 않습니다.

제4조 (광고)

서비스 내에 광고가 포함될 수 있으며, 이는 서비스 운영 비용 충당을 위한 목적입니다.

제5조 (지식재산권)

서비스 내 카드 이미지, 텍스트 등 모든 콘텐츠의 저작권은 회사에 귀속됩니다. 단, 개인적 SNS 공유 목적의 이용은 허용됩니다.

제6조 (약관의 변경)

회사는 필요 시 약관을 변경할 수 있으며, 변경 시 앱 내 공지를 통해 안내합니다.

제7조 (문의)

• 이메일: support@appfactory.kr
''';
