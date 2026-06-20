import 'package:flutter/material.dart';

@immutable
class MyProfileData {
  const MyProfileData({
    this.name = 'User',
    this.email = 'user@fi-you.app',
    this.profileLine = '관찰과 탐구를 좋아하는',
    this.level = 3,
    this.starBalance = 130,
    this.diaryCount = 12,
    this.questionCount = 24,
    this.clueCount = 8,
  });

  final String name;
  final String email;
  final String profileLine;
  final int level;
  final int starBalance;
  final int diaryCount;
  final int questionCount;
  final int clueCount;
}

@immutable
class MyInsightData {
  const MyInsightData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}

@immutable
class StorePackageData {
  const StorePackageData({
    required this.id,
    required this.title,
    required this.stars,
    required this.priceLabel,
    required this.description,
  });

  final String id;
  final String title;
  final int stars;
  final String priceLabel;
  final String description;
}

@immutable
class StarHistoryData {
  const StarHistoryData({
    required this.title,
    required this.dateLabel,
    required this.amount,
  });

  final String title;
  final String dateLabel;
  final int amount;
}

const myDefaultInsights = <MyInsightData>[
  MyInsightData(
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFC4B5FD),
    title: '새로운 단서를 모으는 중',
    description: '최근 기록에서는 생각을 바로 결론내리기보다 조금 더 살펴보려는 흐름이 보여요.',
  ),
  MyInsightData(
    icon: Icons.edit_note_rounded,
    color: Color(0xFF7DD3FC),
    title: '기록 반응이 안정적이에요',
    description: 'Diary와 질문 응답이 쌓일수록 U-Map의 자기탐색 단서가 더 선명해집니다.',
  ),
  MyInsightData(
    icon: Icons.route_rounded,
    color: Color(0xFF6EE7B7),
    title: '관계와 선택 패턴을 탐색 중',
    description: '반복되는 상황에서 어떤 선택이 편하게 느껴지는지 확인하고 있어요.',
  ),
];

const myDefaultPackages = <StorePackageData>[
  StorePackageData(
    id: 'stars_120',
    title: 'Small Star Pack',
    stars: 120,
    priceLabel: 'Google Play 연결 전',
    description: '가벼운 자기탐색 질문과 단서 확인에 사용할 수 있어요.',
  ),
  StorePackageData(
    id: 'stars_360',
    title: 'Focus Star Pack',
    stars: 360,
    priceLabel: 'Google Play 연결 전',
    description: 'Growth Map과 Relation Map을 여유 있게 살펴보기 좋은 구성입니다.',
  ),
  StorePackageData(
    id: 'stars_760',
    title: 'Deep Dive Pack',
    stars: 760,
    priceLabel: 'Google Play 연결 전',
    description: '여러 기록 흐름을 이어서 탐구하려는 사용자에게 맞춘 mock 패키지입니다.',
  ),
];

const myDefaultHistory = <StarHistoryData>[
  StarHistoryData(title: '오늘의 탐구 보상', dateLabel: '2026.06.19', amount: 20),
  StarHistoryData(title: 'Growth Map 열람', dateLabel: '2026.06.18', amount: -30),
  StarHistoryData(title: 'Diary 기록 보상', dateLabel: '2026.06.17', amount: 10),
  StarHistoryData(
    title: 'Relation Map 열람',
    dateLabel: '2026.06.16',
    amount: -30,
  ),
];
