import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../models/fiyou_models.dart';
import 'mock_self_discovery_repository.dart';
import 'self_discovery_repository.dart';
import 'supabase_self_discovery_repository.dart';

final selfDiscoveryRepositoryProvider = Provider<SelfDiscoveryRepository>((ref) {
  if (AppConfig.hasSupabaseConfig) {
    return SupabaseSelfDiscoveryRepository(Supabase.instance.client);
  }
  if (AppConfig.canUseMockRepository) {
    return MockSelfDiscoveryRepository();
  }
  throw StateError(
    'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are required for production builds.',
  );
});

final currentProfileProvider = FutureProvider<FiyouProfile?>((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getCurrentProfile();
});

final todaySummaryProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getTodaySummary();
});

final nextQuestionProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getNextQuestion();
});

final diariesProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getDiaries();
});

final diaryProvider = FutureProvider.family((ref, String id) {
  return ref.watch(selfDiscoveryRepositoryProvider).getDiary(id);
});

final uMapProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getUMap();
});

final signatureProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getSignature();
});

final storeProductsProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getStoreProducts();
});

final relationsProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getRelations();
});

final reportsProvider = FutureProvider((ref) {
  return ref.watch(selfDiscoveryRepositoryProvider).getReports();
});
