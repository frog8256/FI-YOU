class FiyouProfile {
  const FiyouProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.timezone = 'Asia/Seoul',
    this.onboardingCompleted = false,
  });

  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String timezone;
  final bool onboardingCompleted;
}

class QuestionChoice {
  const QuestionChoice({
    required this.id,
    required this.label,
    this.signalHints = const [],
  });

  final String id;
  final String label;
  final List<String> signalHints;
}

class Question {
  const Question({
    required this.id,
    required this.prompt,
    required this.category,
    required this.type,
    this.subtitle,
    this.choices = const [],
    this.optionalTextPrompt = '덧붙이고 싶은 말이 있나요?',
    this.whyThisQuestion,
  });

  final String id;
  final String prompt;
  final String category;
  final String type;
  final String? subtitle;
  final List<QuestionChoice> choices;
  final String optionalTextPrompt;
  final String? whyThisQuestion;
}

class AnswerDraft {
  const AnswerDraft({
    required this.questionId,
    required this.selectedChoiceIds,
    this.freeText,
  });

  final String questionId;
  final List<String> selectedChoiceIds;
  final String? freeText;
}

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.entryDate,
    required this.body,
    this.title,
    this.moodScore,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DateTime entryDate;
  final String? title;
  final String body;
  final int? moodScore;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DiaryEntry copyWith({
    String? id,
    DateTime? entryDate,
    String? title,
    String? body,
    int? moodScore,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      title: title ?? this.title,
      body: body ?? this.body,
      moodScore: moodScore ?? this.moodScore,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UMapAxis {
  const UMapAxis({
    required this.code,
    required this.label,
    required this.summary,
    required this.score,
    required this.clarity,
    required this.flow,
    this.signals = const [],
    this.nextDepth,
  });

  final String code;
  final String label;
  final String summary;
  final double score;
  final double clarity;
  final String flow;
  final List<String> signals;
  final String? nextDepth;
}

class UMapSnapshot {
  const UMapSnapshot({
    required this.axes,
    required this.overallClarity,
    this.clearAreas = const [],
    this.unclearAreas = const [],
    this.nextQuestionFocus = const [],
  });

  final List<UMapAxis> axes;
  final double overallClarity;
  final List<String> clearAreas;
  final List<String> unclearAreas;
  final List<String> nextQuestionFocus;
}

class SignatureFlow {
  const SignatureFlow({
    required this.label,
    required this.summary,
    required this.confidenceNote,
    this.evidence = const [],
  });

  final String label;
  final String summary;
  final String confidenceNote;
  final List<String> evidence;
}

class StarBalance {
  const StarBalance({required this.balance});

  final int balance;
}

class Entitlement {
  const Entitlement({
    required this.id,
    required this.productId,
    required this.status,
    this.expiresAt,
  });

  final String id;
  final String productId;
  final String status;
  final DateTime? expiresAt;
}

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.kind,
    this.starAmount,
  });

  final String id;
  final String title;
  final String description;
  final String priceLabel;
  final String kind;
  final int? starAmount;
}

class PaidReport {
  const PaidReport({
    required this.id,
    required this.title,
    required this.status,
    this.summary,
    this.requiredProductId,
  });

  final String id;
  final String title;
  final String status;
  final String? summary;
  final String? requiredProductId;
}

class RelationItem {
  const RelationItem({
    required this.id,
    required this.label,
    required this.status,
    this.note,
  });

  final String id;
  final String label;
  final String status;
  final String? note;
}

class TodaySummary {
  const TodaySummary({
    required this.question,
    required this.diaries,
    required this.uMap,
    required this.signature,
    required this.starBalance,
    required this.entitlements,
    required this.relations,
    required this.reports,
  });

  final Question question;
  final List<DiaryEntry> diaries;
  final UMapSnapshot uMap;
  final SignatureFlow signature;
  final StarBalance starBalance;
  final List<Entitlement> entitlements;
  final List<RelationItem> relations;
  final List<PaidReport> reports;
}
