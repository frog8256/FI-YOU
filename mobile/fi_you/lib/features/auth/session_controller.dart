import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/fiyou_models.dart';
import '../../data/repositories/repository_providers.dart';

class AppSession {
  const AppSession({
    required this.isSignedIn,
    required this.onboardingCompleted,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  const AppSession.initial()
      : isSignedIn = false,
        onboardingCompleted = false,
        profile = null,
        isLoading = true,
        errorMessage = null;

  final bool isSignedIn;
  final bool onboardingCompleted;
  final FiyouProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  AppSession copyWith({
    bool? isSignedIn,
    bool? onboardingCompleted,
    FiyouProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppSession(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AppSessionController extends Notifier<AppSession> {
  @override
  AppSession build() {
    unawaited(_restore());
    return const AppSession.initial();
  }

  Future<void> _restore() async {
    try {
      final profile = await ref.read(selfDiscoveryRepositoryProvider).getCurrentProfile();
      state = state.copyWith(
        isSignedIn: profile != null,
        onboardingCompleted: profile?.onboardingCompleted ?? false,
        profile: profile,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isSignedIn: false,
        onboardingCompleted: false,
        isLoading: false,
        errorMessage: '앱 설정을 확인하지 못했어요.',
      );
    }
  }

  Future<void> signInWithEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await ref.read(selfDiscoveryRepositoryProvider).signInWithEmail(email);
      state = state.copyWith(
        isSignedIn: true,
        onboardingCompleted: profile.onboardingCompleted,
        profile: profile,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했어요. 잠시 후 다시 시도해주세요.',
      );
    }
  }

  Future<void> completeOnboarding(String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await ref.read(selfDiscoveryRepositoryProvider).completeOnboarding(
            displayName: displayName,
            timezone: 'Asia/Seoul',
          );
      state = state.copyWith(
        profile: profile,
        onboardingCompleted: profile.onboardingCompleted,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '온보딩 저장에 실패했어요.',
      );
    }
  }

  Future<void> signOut() async {
    await ref.read(selfDiscoveryRepositoryProvider).signOut();
    state = const AppSession(
      isSignedIn: false,
      onboardingCompleted: false,
      isLoading: false,
    );
  }
}

final appSessionProvider = NotifierProvider<AppSessionController, AppSession>(
  AppSessionController.new,
);
