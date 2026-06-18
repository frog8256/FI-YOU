import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FiYouApp extends ConsumerWidget {
  const FiYouApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FI-YOU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
      supportedLocales: const [Locale('ko'), Locale('en')],
      locale: const Locale('ko'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
