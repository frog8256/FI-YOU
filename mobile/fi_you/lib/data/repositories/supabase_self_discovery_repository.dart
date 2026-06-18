import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fiyou_models.dart';
import 'self_discovery_repository.dart';

class SupabaseSelfDiscoveryRepository implements SelfDiscoveryRepository {
  SupabaseSelfDiscoveryRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw AuthException('로그인이 필요해요.');
    return id;
  }

  @override
  Future<FiyouProfile?> getCurrentProfile() async {
    if (_client.auth.currentSession == null) return null;
    final row = await _client.rpc('get_my_profile');
    if (row == null) return null;
    return _profileFromJson(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<FiyouProfile> signInWithEmail(String email) async {
    await _client.auth.signInWithOtp(email: email);
    return FiyouProfile(id: _client.auth.currentUser?.id ?? '', displayName: email);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<FiyouProfile> completeOnboarding({
    required String displayName,
    required String timezone,
  }) async {
    final row = await _client.rpc(
      'upsert_my_profile',
      params: {
        'display_name': displayName,
        'avatar_url': null,
        'timezone': timezone,
      },
    );
    return _profileFromJson(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<TodaySummary> getTodaySummary() async {
    return TodaySummary(
      question: await getNextQuestion(),
      diaries: await getDiaries(),
      uMap: await getUMap(),
      signature: await getSignature(),
      starBalance: await getStarBalance(),
      entitlements: await getEntitlements(),
      relations: await getRelations(),
      reports: await getReports(),
    );
  }

  @override
  Future<Question> getNextQuestion() async {
    final row = await _client.rpc('get_next_question');
    return _questionFromJson(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<void> submitAnswer(AnswerDraft draft) async {
    await _client.rpc(
      'upsert_my_answer',
      params: {
        'question_id': draft.questionId,
        'answer_text': draft.freeText,
        'answer_value': {'choices': draft.selectedChoiceIds},
      },
    );
  }

  @override
  Future<List<DiaryEntry>> getDiaries() async {
    final rows = await _client.rpc('get_my_diaries', params: {
      'from_date': null,
      'to_date': null,
    });
    return _asList(rows).map(_diaryFromJson).toList();
  }

  @override
  Future<DiaryEntry?> getDiary(String id) async {
    final row = await _client.rpc('get_my_diary', params: {'id': id});
    return row == null ? null : _diaryFromJson(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<DiaryEntry> saveDiary(DiaryEntry entry) async {
    final params = {
      'entry_date': _dateOnly(entry.entryDate),
      'title': entry.title,
      'body': entry.body,
      'mood_score': entry.moodScore,
      'tags': entry.tags,
    };
    final row = entry.id == 'new'
        ? await _client.rpc('create_my_diary', params: params)
        : await _client.rpc('update_my_diary', params: {'id': entry.id, ...params});
    return _diaryFromJson(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<void> deleteDiary(String id) async {
    await _client.rpc('delete_my_diary', params: {'id': id});
  }

  @override
  Future<UMapSnapshot> getUMap() async {
    final rows = await _client.rpc('get_my_u_map');
    final axes = _asList(rows).map((row) {
      final clarity = _double(row['clarity'] ?? row['confidence'] ?? 0);
      return UMapAxis(
        code: row['code'] as String? ?? row['traitCode'] as String? ?? '',
        label: row['label'] as String? ?? row['name'] as String? ?? '탐험 영역',
        summary: row['summary'] as String? ?? '현재 기록에서 보이는 흐름이에요.',
        score: _double(row['score']).clamp(0, 100).toDouble(),
        clarity: clarity <= 1
            ? (clarity * 100).clamp(0, 100).toDouble()
            : clarity.clamp(0, 100).toDouble(),
        flow: row['flow'] as String? ?? 'emerging',
        signals: _stringList(row['signals']),
        nextDepth: row['nextDepth'] as String?,
      );
    }).toList();
    final clarity = axes.isEmpty
        ? 0.0
        : axes.map((axis) => axis.clarity).reduce((a, b) => a + b) / axes.length;
    return UMapSnapshot(axes: axes, overallClarity: clarity);
  }

  @override
  Future<SignatureFlow> getSignature() async {
    final row = await _client.rpc('get_current_signature', params: {
      'signature_type': 'primary',
    });
    if (row == null) {
      return const SignatureFlow(
        label: '아직 흐름을 모으는 중',
        summary: '질문과 Diary가 쌓이면 현재 기록에서 보이는 흐름을 보여드릴게요.',
        confidenceNote: '고정된 유형이 아니라 기록에 따라 달라지는 표현이에요.',
      );
    }
    final json = Map<String, dynamic>.from(row as Map);
    return SignatureFlow(
      label: json['label'] as String? ?? json['name'] as String? ?? '현재 흐름',
      summary: json['summary'] as String? ?? '',
      confidenceNote: json['confidenceNote'] as String? ?? '기록이 쌓이면 표현도 달라질 수 있어요.',
      evidence: _stringList(json['evidence']),
    );
  }

  @override
  Future<StarBalance> getStarBalance() async {
    final row = await _client.rpc('get_my_star_balance');
    final json = row is Map ? Map<String, dynamic>.from(row) : {'balance': row};
    return StarBalance(balance: (json['balance'] as num?)?.toInt() ?? 0);
  }

  @override
  Future<List<Entitlement>> getEntitlements() async {
    final rows = await _client.rpc('get_my_entitlements');
    return _asList(rows).map((row) {
      return Entitlement(
        id: row['id'] as String,
        productId: row['productId'] as String? ?? row['product_id'] as String? ?? '',
        status: row['status'] as String? ?? 'unknown',
        expiresAt: _dateTimeOrNull(row['expiresAt'] ?? row['expires_at']),
      );
    }).toList();
  }

  @override
  Future<List<StoreProduct>> getStoreProducts() async {
    final rows = await _client.rpc('get_store_products', params: {'platform': 'android'});
    return _asList(rows).map((row) {
      return StoreProduct(
        id: row['id'] as String? ?? row['productId'] as String? ?? row['product_id'] as String,
        title: row['title'] as String? ?? '탐험 상품',
        description: row['description'] as String? ?? '',
        priceLabel: row['priceLabel'] as String? ?? row['price_label'] as String? ?? 'Google Play',
        kind: row['kind'] as String? ?? 'consumable',
        starAmount: (row['starAmount'] as num? ?? row['star_amount'] as num?)?.toInt(),
      );
    }).toList();
  }

  @override
  Future<void> submitPurchaseToken({
    required String productId,
    required String purchaseToken,
    required String source,
  }) async {
    final response = await _client.functions.invoke(
      'verify-google-play-purchase',
      body: {
        'packageName': 'com.fiyou.app',
        'productId': productId,
        'purchaseToken': purchaseToken,
        'source': source,
        ..._purchaseMetadata(productId),
      },
    );
    if (response.status >= 400) {
      throw Exception('결제 검증에 실패했어요.');
    }
  }

  @override
  Future<List<RelationItem>> getRelations() async {
    final rows = await _client.rpc('get_my_relations');
    return _asList(rows).map((row) {
      return RelationItem(
        id: row['id'] as String,
        label: row['label'] as String? ?? '관계',
        status: row['status'] as String? ?? 'draft',
        note: row['note'] as String?,
      );
    }).toList();
  }

  @override
  Future<RelationItem> createRelation({required String label, String? note}) async {
    final row = await _client.rpc(
      'create_my_relation',
      params: {'label': label, 'note': note},
    );
    final json = Map<String, dynamic>.from(row as Map);
    return RelationItem(
      id: json['id'] as String,
      label: json['label'] as String? ?? label,
      status: json['status'] as String? ?? 'draft',
      note: json['note'] as String?,
    );
  }

  @override
  Future<List<PaidReport>> getReports() async {
    final rows = await _client.rpc('get_my_reports');
    return _asList(rows).map((row) {
      return PaidReport(
        id: row['id'] as String,
        title: row['title'] as String? ?? '리포트',
        status: row['status'] as String? ?? 'pending',
        summary: row['summary'] as String?,
        requiredProductId: row['requiredProductId'] as String? ?? row['required_product_id'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> requestAccountDeletion({String? reason}) async {
    await _client.rpc('request_account_deletion', params: {'reason': reason});
  }

  FiyouProfile _profileFromJson(Map<String, dynamic> json) {
    return FiyouProfile(
      id: json['id'] as String? ?? _userId,
      displayName: json['displayName'] as String? ?? json['display_name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Seoul',
      onboardingCompleted: json['onboardingCompleted'] as bool? ??
          json['onboarding_completed'] as bool? ??
          true,
    );
  }

  Question _questionFromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? json['questionId'] as String,
      prompt: json['prompt'] as String? ?? json['question'] as String,
      category: json['category'] as String? ?? json['axis'] as String? ?? '',
      type: json['questionType'] as String? ?? json['question_type'] as String? ?? 'single_choice',
      subtitle: json['subtitle'] as String?,
      optionalTextPrompt: json['optionalTextPrompt'] as String? ??
          json['optional_text_prompt'] as String? ??
          '덧붙이고 싶은 말이 있나요?',
      whyThisQuestion: json['whyThisQuestion'] as String? ?? json['why_this_question'] as String?,
      choices: _choicesFromJson(json['choices'] ?? json['answerSchema'] ?? json['answer_schema']),
    );
  }

  List<QuestionChoice> _choicesFromJson(dynamic source) {
    final choices = source is Map ? source['choices'] : source;
    if (choices is! List) return const [];
    return choices.whereType<Map>().map((item) {
      final json = Map<String, dynamic>.from(item);
      return QuestionChoice(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        signalHints: _stringList(json['signalHints'] ?? json['signal_hints']),
      );
    }).toList();
  }

  DiaryEntry _diaryFromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      entryDate: DateTime.parse(json['entryDate'] as String? ?? json['entry_date'] as String),
      title: json['title'] as String?,
      body: json['body'] as String,
      moodScore: (json['moodScore'] as num? ?? json['mood_score'] as num?)?.toInt(),
      tags: _stringList(json['tags']),
      createdAt: _dateTimeOrNull(json['createdAt'] ?? json['created_at']),
      updatedAt: _dateTimeOrNull(json['updatedAt'] ?? json['updated_at']),
    );
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;

  DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Map<String, Object?> _purchaseMetadata(String productId) {
    switch (productId) {
      case 'fiyou_star_100':
        return {'productType': 'inapp', 'amountStars': 100, 'entitlementType': 'star_pack'};
      case 'fiyou_star_300':
        return {'productType': 'inapp', 'amountStars': 330, 'entitlementType': 'star_pack'};
      case 'fiyou_star_700':
        return {'productType': 'inapp', 'amountStars': 800, 'entitlementType': 'star_pack'};
      case 'fiyou_star_1500':
        return {'productType': 'inapp', 'amountStars': 1800, 'entitlementType': 'star_pack'};
      case 'fiyou_report_umap_deep_1':
      case 'fiyou_report_signature_deep_1':
      case 'fiyou_report_past_self_1':
        return {
          'productType': 'inapp',
          'entitlementType': 'paid_report',
          'resourceType': 'report_template',
          'productCode': productId,
        };
      case 'fiyou_report_relation_1':
        return {
          'productType': 'inapp',
          'entitlementType': 'paid_report',
          'resourceType': 'relation_report',
          'productCode': productId,
        };
      case 'fiyou_plus':
        return {
          'productType': 'subscription',
          'entitlementType': 'subscription',
          'resourceType': 'plan',
          'productCode': productId,
        };
      default:
        return {'productType': 'inapp', 'productCode': productId};
    }
  }
}
