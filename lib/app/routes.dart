import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/card/ui/screens/splash_screen.dart';
import '../features/card/ui/screens/home_screen.dart';
import '../features/collection/ui/screens/collection_screen.dart';
import '../features/collection/ui/screens/card_detail_screen.dart';
import '../features/settings/ui/screens/settings_screen.dart';
import '../features/settings/ui/screens/legal_screen.dart';

/// 앱 라우터 설정
///
/// 경로 구조:
/// /splash              → SplashScreen (초기 경로)
/// /home                → HomeScreen (ShellRoute)
/// /collection          → CollectionScreen (ShellRoute)
/// /collection/:cardId  → CardDetailScreen (ShellRoute 아래)
/// /settings            → SettingsScreen (ShellRoute)
/// /privacy             → LegalScreen(privacy)
/// /terms               → LegalScreen(terms)
class AppRouter {
  AppRouter._();

  // ==================== 경로 상수 ====================

  static const String splash = '/splash';
  static const String home = '/home';
  static const String collection = '/collection';
  static const String cardDetail = '/collection/:cardId';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';

  // ==================== GoRouter 인스턴스 ====================

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      // 스플래시 (ShellRoute 밖)
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 법적 요건 화면 (ShellRoute 밖 — BottomNav 없음)
      GoRoute(
        path: privacy,
        name: 'privacy',
        builder: (context, state) =>
            const LegalScreen(type: LegalType.privacy),
      ),
      GoRoute(
        path: terms,
        name: 'terms',
        builder: (context, state) =>
            const LegalScreen(type: LegalType.terms),
      ),

      // ShellRoute: 홈 / 도감 / 설정 (공통 BottomNavigationBar)
      ShellRoute(
        builder: (context, state, child) =>
            _MainShell(child: child, location: state.uri.path),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: collection,
            name: 'collection',
            builder: (context, state) => const CollectionScreen(),
            routes: [
              GoRoute(
                path: ':cardId',
                name: 'cardDetail',
                builder: (context, state) {
                  final cardId =
                      state.pathParameters['cardId'] ?? '';
                  return CardDetailScreen(cardId: cardId);
                },
              ),
            ],
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

// ==================== 메인 Shell 위젯 ====================

/// ShellRoute 래퍼 — 하단 내비게이션 바 포함
class _MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const _MainShell({
    required this.child,
    required this.location,
  });

  int _currentIndex(String location) {
    if (location.startsWith('/collection')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0; // /home (기본)
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(location);

    // ShellRoute의 child는 각 화면 자체의 Scaffold를 포함하므로
    // 여기서는 BottomNavigationBar 삽입만 담당.
    return Scaffold(
      // child 화면의 Scaffold AppBar/Body를 그대로 유지
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.home);
            case 1:
              context.go(AppRouter.collection);
            case 2:
              context.go(AppRouter.settings);
            default:
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: '오늘의 카드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: '도감',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}

