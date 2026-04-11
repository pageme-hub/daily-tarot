import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes.dart';
import 'shared/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';
import 'core/initialization/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // .env 로드
  await dotenv.load(fileName: '.env');

  // 앱 초기화 (Hive, Supabase, Firebase, AdMob 순)
  await AppInitializer.initialize();

  runApp(
    const ProviderScope(
      child: DailyTarotApp(),
    ),
  );
}

class DailyTarotApp extends ConsumerWidget {
  const DailyTarotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: '매일타로',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
