import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screen.dart';
import '../../features/auth/session_controller.dart';
import '../../features/diary/diary_detail_screen.dart';
import '../../features/diary/diary_edit_screen.dart';
import '../../features/diary/diary_list_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/questions/question_response_screen.dart';
import '../../features/relations/relations_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/signature/signature_screen.dart';
import '../../features/store/store_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/umap/u_map_screen.dart';
import '../navigation/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(appSessionProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/today',
    redirect: (context, state) {
      final location = state.uri.path;
      if (session.isLoading) return location == '/splash' ? null : '/splash';
      if (location == '/splash') {
        if (!session.isSignedIn) return '/auth';
        if (!session.onboardingCompleted) return '/onboarding';
        return '/today';
      }
      final isAuthRoute = location == '/auth';
      final isOnboardingRoute = location == '/onboarding';

      if (!session.isSignedIn) {
        return isAuthRoute ? null : '/auth';
      }

      if (!session.onboardingCompleted) {
        return isOnboardingRoute ? null : '/onboarding';
      }

      if (isAuthRoute || isOnboardingRoute) return '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
          GoRoute(
            path: '/question',
            builder: (context, state) => const QuestionResponseScreen(),
          ),
          GoRoute(path: '/diary', builder: (context, state) => const DiaryListScreen()),
          GoRoute(
            path: '/diary/new',
            builder: (context, state) => const DiaryEditScreen(id: 'new'),
          ),
          GoRoute(
            path: '/diary/:id',
            builder: (context, state) => DiaryDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/diary/:id/edit',
            builder: (context, state) => DiaryEditScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(path: '/u-map', builder: (context, state) => const UMapScreen()),
          GoRoute(path: '/signature', builder: (context, state) => const SignatureScreen()),
          GoRoute(path: '/relations', builder: (context, state) => const RelationsScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/store', builder: (context, state) => const StoreScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(
            path: '/legal/:type',
            builder: (context, state) => LegalScreen(type: state.pathParameters['type']!),
          ),
        ],
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF090817),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
