import '../models/fiyou_models.dart';

abstract class SelfDiscoveryRepository {
  Future<FiyouProfile?> getCurrentProfile();

  Future<FiyouProfile> signInWithEmail(String email);

  Future<void> signOut();

  Future<FiyouProfile> completeOnboarding({
    required String displayName,
    required String timezone,
  });

  Future<TodaySummary> getTodaySummary();

  Future<Question> getNextQuestion();

  Future<void> submitAnswer(AnswerDraft draft);

  Future<List<DiaryEntry>> getDiaries();

  Future<DiaryEntry?> getDiary(String id);

  Future<DiaryEntry> saveDiary(DiaryEntry entry);

  Future<void> deleteDiary(String id);

  Future<UMapSnapshot> getUMap();

  Future<SignatureFlow> getSignature();

  Future<StarBalance> getStarBalance();

  Future<List<Entitlement>> getEntitlements();

  Future<List<StoreProduct>> getStoreProducts();

  Future<void> submitPurchaseToken({
    required String productId,
    required String purchaseToken,
    required String source,
  });

  Future<List<RelationItem>> getRelations();

  Future<RelationItem> createRelation({
    required String label,
    String? note,
  });

  Future<List<PaidReport>> getReports();

  Future<void> requestAccountDeletion({String? reason});
}
