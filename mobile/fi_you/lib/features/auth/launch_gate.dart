import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/features/auth/auth_return_screen.dart';
import 'package:fi_you/features/auth/intro_screen.dart';
import 'package:fi_you/features/auth/login_screen.dart';
import 'package:fi_you/features/auth/onboarding_entry_screen.dart';
import 'package:flutter/material.dart';

typedef AuthAppShellBuilder = Widget Function(BuildContext context);
typedef AuthOnboardingBuilder =
    Widget Function(BuildContext context, VoidCallback onRefresh);

enum _AuthRoute { intro, login, authReturn, onboarding, ready, error }

class LaunchGate extends StatefulWidget {
  const LaunchGate({
    required this.repository,
    required this.appShellBuilder,
    this.onboardingBuilder,
    super.key,
  });

  final FiYouRepository repository;
  final AuthAppShellBuilder appShellBuilder;
  final AuthOnboardingBuilder? onboardingBuilder;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> with WidgetsBindingObserver {
  _AuthRoute _route = _AuthRoute.authReturn;
  String? _errorMessage;
  bool _restoring = false;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        (_route == _AuthRoute.authReturn || _route == _AuthRoute.intro)) {
      _restore();
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    setState(() {
      _restoring = true;
      _errorMessage = null;
      if (_route != _AuthRoute.ready && _route != _AuthRoute.onboarding) {
        _route = _AuthRoute.authReturn;
      }
    });

    try {
      final snapshot = await widget.repository.restoreLaunchState();
      if (!mounted) return;
      setState(() {
        _route = switch (snapshot.status) {
          LaunchStatus.checking => _AuthRoute.authReturn,
          LaunchStatus.signedOut => _AuthRoute.intro,
          LaunchStatus.onboardingRequired => _AuthRoute.onboarding,
          LaunchStatus.ready => _AuthRoute.ready,
          LaunchStatus.error => _AuthRoute.error,
        };
        _errorMessage = snapshot.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _route = _AuthRoute.error;
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _route = _AuthRoute.authReturn;
      _errorMessage = null;
    });

    try {
      await widget.repository.signIn();
      if (!mounted) return;
      setState(() {
        _route = widget.repository is MockFiYouRepository
            ? _AuthRoute.ready
            : _AuthRoute.authReturn;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _route = _AuthRoute.error;
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_route) {
      _AuthRoute.intro => IntroScreen(
        onContinue: () => setState(() => _route = _AuthRoute.login),
      ),
      _AuthRoute.login => LoginScreen(onGoogleSignIn: _signIn),
      _AuthRoute.authReturn => const AuthReturnScreen(),
      _AuthRoute.onboarding =>
        widget.onboardingBuilder?.call(context, _restore) ??
            OnboardingEntryScreen(onRefresh: _restore),
      _AuthRoute.ready => widget.appShellBuilder(context),
      _AuthRoute.error => _LaunchErrorScreen(
        message: _errorMessage,
        onRetry: _restore,
      ),
    };
  }
}

class _LaunchErrorScreen extends StatelessWidget {
  const _LaunchErrorScreen({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: FiYouGlass.gold,
                  size: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  '시작 상태를 불러오지 못했어요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message?.isNotEmpty == true
                      ? message!
                      : '네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
