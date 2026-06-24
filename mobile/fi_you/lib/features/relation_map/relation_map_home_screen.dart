import 'dart:math' as math;

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class RelationMapHomeScreen extends StatelessWidget {
  const RelationMapHomeScreen({super.key});

  static const _profiles = [
    RelationProfilePreview(
      displayName: '엄마',
      relationLabel: '어머니',
      knownDurationLabel: '아주 오래',
      closenessScore: 8,
      status: RelationProfileStatus.mapReady,
      answeredCount: 5,
      lastSummary: '고마움과 부담감이 함께 연결돼요.',
      updatedLabel: '오늘 업데이트',
      accentColor: _RelationMapColors.coral,
      icon: Icons.volunteer_activism_rounded,
    ),
    RelationProfilePreview(
      displayName: '민지',
      relationLabel: '친구',
      knownDurationLabel: '3년 ~ 10년',
      closenessScore: 6,
      status: RelationProfileStatus.inProgress,
      answeredCount: 3,
      lastSummary: '가깝지만 먼저 다가가는 타이밍을 조심하고 있어요.',
      updatedLabel: '2일 전',
      accentColor: _RelationMapColors.cyan,
      icon: Icons.favorite_border_rounded,
    ),
    RelationProfilePreview(
      displayName: '아빠',
      relationLabel: '아버지',
      knownDurationLabel: '아주 오래',
      closenessScore: 5,
      status: RelationProfileStatus.profileOnly,
      answeredCount: 1,
      lastSummary: '아직 관계 질문이 조금 더 필요해요.',
      updatedLabel: '5일 전',
      accentColor: _RelationMapColors.gold,
      icon: Icons.home_rounded,
    ),
    RelationProfilePreview(
      displayName: 'J',
      relationLabel: '직장/학교',
      knownDurationLabel: '1년 ~ 3년',
      closenessScore: 4,
      status: RelationProfileStatus.inProgress,
      answeredCount: 2,
      lastSummary: '편안함보다 조심스러운 거리감이 먼저 보여요.',
      updatedLabel: '1주 전',
      accentColor: _RelationMapColors.emerald,
      icon: Icons.work_outline_rounded,
    ),
    RelationProfilePreview(
      displayName: '현우',
      relationLabel: '친구',
      knownDurationLabel: '10년 이상',
      closenessScore: 7,
      status: RelationProfileStatus.updated,
      answeredCount: 4,
      lastSummary: '오래된 편안함과 표현하지 않은 서운함이 함께 있어요.',
      updatedLabel: '어제',
      accentColor: _RelationMapColors.violet,
      icon: Icons.people_alt_rounded,
    ),
    RelationProfilePreview(
      displayName: '팀장님',
      relationLabel: '직장/학교',
      knownDurationLabel: '6개월 ~ 1년',
      closenessScore: 3,
      status: RelationProfileStatus.inProgress,
      answeredCount: 2,
      lastSummary: '인정받고 싶은 마음과 부담감이 같이 나타나요.',
      updatedLabel: '3일 전',
      accentColor: _RelationMapColors.blue,
      icon: Icons.badge_outlined,
    ),
    RelationProfilePreview(
      displayName: '수아',
      relationLabel: '친구',
      knownDurationLabel: '1년 ~ 3년',
      closenessScore: 6,
      status: RelationProfileStatus.mapReady,
      answeredCount: 4,
      lastSummary: '가까워지고 싶지만 먼저 말하기 전 망설임이 있어요.',
      updatedLabel: '4일 전',
      accentColor: _RelationMapColors.mint,
      icon: Icons.chat_bubble_outline_rounded,
    ),
    RelationProfilePreview(
      displayName: '동생',
      relationLabel: '형제/자매',
      knownDurationLabel: '아주 오래',
      closenessScore: 7,
      status: RelationProfileStatus.updated,
      answeredCount: 6,
      lastSummary: '익숙함 속에서 챙겨주려는 흐름이 보여요.',
      updatedLabel: '오늘 업데이트',
      accentColor: _RelationMapColors.pink,
      icon: Icons.handshake_rounded,
    ),
    RelationProfilePreview(
      displayName: '선배',
      relationLabel: '지인',
      knownDurationLabel: '3년 ~ 10년',
      closenessScore: 4,
      status: RelationProfileStatus.profileOnly,
      answeredCount: 0,
      lastSummary: '첫 질문을 시작하면 관계 단서를 모을 수 있어요.',
      updatedLabel: '대기 중',
      accentColor: _RelationMapColors.slate,
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).padding.bottom + 28;
    final visibleProfiles = _profiles.take(8).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, bottomSpace),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  const _Header(),
                  const SizedBox(height: 18),
                  _RelationDashboard(
                    profiles: visibleProfiles,
                    hiddenCount: _profiles.length - visibleProfiles.length,
                    onProfileTap: () => _showComingSoon(context),
                  ),
                  const SizedBox(height: 14),
                  _CreateRelationCard(onTap: () => _showComingSoon(context)),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: '내 관계', actionLabel: '최근순'),
                  const SizedBox(height: 10),
                  for (final profile in _profiles.take(3)) ...[
                    _RelationProfileCard(
                      profile: profile,
                      onTap: () => _showComingSoon(context),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 6),
                  const _RecentCluesSection(),
                  const SizedBox(height: 14),
                  _DailyQuestionCard(onTap: () => _showComingSoon(context)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('관계 질문 화면은 다음 단계에서 연결됩니다.')));
  }
}

class RelationProfilePreview {
  const RelationProfilePreview({
    required this.displayName,
    required this.relationLabel,
    required this.knownDurationLabel,
    required this.closenessScore,
    required this.status,
    required this.answeredCount,
    required this.lastSummary,
    required this.updatedLabel,
    required this.accentColor,
    required this.icon,
  });

  final String displayName;
  final String relationLabel;
  final String knownDurationLabel;
  final int closenessScore;
  final RelationProfileStatus status;
  final int answeredCount;
  final String lastSummary;
  final String updatedLabel;
  final Color accentColor;
  final IconData icon;
}

enum RelationProfileStatus { profileOnly, inProgress, mapReady, updated }

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FiYouLiquidIconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              label: '뒤로가기',
              onPressed: () => Navigator.of(context).maybePop(),
              size: 38,
              radius: 13,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Relation Map',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          '내가 맺고 있는 관계들을 하나씩 살펴봐요.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '상대의 마음을 단정하지 않고, 내 기록을 바탕으로 관계의 흐름을 정리합니다.',
          style: TextStyle(
            color: _RelationMapColors.textSoft,
            fontSize: 12.6,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RelationDashboard extends StatelessWidget {
  const _RelationDashboard({
    required this.profiles,
    required this.hiddenCount,
    required this.onProfileTap,
  });

  final List<RelationProfilePreview> profiles;
  final int hiddenCount;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final double average = profiles.isEmpty
        ? 0
        : profiles
                  .map((profile) => profile.closenessScore)
                  .reduce((a, b) => a + b) /
              profiles.length;
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(16),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: _RelationMapColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '관계 대시보드', actionLabel: '최대 8명'),
          const SizedBox(height: 16),
          Row(
            children: [
              _ClosenessDonut(value: average),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '관계 친밀도',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${profiles.length}개의 관계에서 평균 ${average.toStringAsFixed(1)}/10로 느껴져요.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _RelationMapColors.textMuted,
                        fontSize: 12.1,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '친밀도는 상대의 마음이 아니라, 내가 현재 느끼는 가까움의 기준이에요.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _RelationMapColors.textSoft,
                        fontSize: 11.5,
                        height: 1.36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: profiles.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              return _DashboardRelationBox(
                profile: profiles[index],
                onTap: onProfileTap,
              );
            },
          ),
          if (hiddenCount > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                '$hiddenCount개의 관계가 접혀 있어요.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _RelationMapColors.textMuted,
                  fontSize: 11.4,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClosenessDonut extends StatelessWidget {
  const _ClosenessDonut({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 94,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(94),
            painter: _DonutPainter(value / 10),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                '/10',
                style: TextStyle(
                  color: _RelationMapColors.textMuted,
                  fontSize: 10.5,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 7;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.1);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          _RelationMapColors.cyan,
          _RelationMapColors.emerald,
          _RelationMapColors.coral,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0).toDouble(),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DashboardRelationBox extends StatelessWidget {
  const _DashboardRelationBox({required this.profile, required this.onTap});

  final RelationProfilePreview profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(profile.icon, color: profile.accentColor, size: 19),
              const SizedBox(height: 5),
              Text(
                profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.2,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${profile.closenessScore}/10',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: profile.accentColor,
                  fontSize: 10.5,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRelationCard extends StatelessWidget {
  const _CreateRelationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(15),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: _RelationMapColors.border,
      onTap: onTap,
      child: const Row(
        children: [
          _RoundIcon(icon: Icons.add_rounded, color: _RelationMapColors.cyan),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '새로운 관계 추가',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '이름, 관계, 알고 지낸 기간, 친밀도를 먼저 기록해요.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _RelationMapColors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded, color: _RelationMapColors.textSoft),
        ],
      ),
    );
  }
}

class _RelationProfileCard extends StatelessWidget {
  const _RelationProfileCard({required this.profile, required this.onTap});

  final RelationProfilePreview profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(16),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: _RelationMapColors.border,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundIcon(icon: profile.icon, color: profile.accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.relationLabel} · ${profile.knownDurationLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _RelationMapColors.textMuted,
                        fontSize: 11.8,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: profile.status, color: profile.accentColor),
            ],
          ),
          const SizedBox(height: 14),
          _ClosenessMeter(
            value: profile.closenessScore,
            color: profile.accentColor,
          ),
          const SizedBox(height: 14),
          Text(
            profile.lastSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.3,
              height: 1.38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${profile.answeredCount}개의 관계 단서 · ${profile.updatedLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _RelationMapColors.textMuted,
                    fontSize: 11.3,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _ctaForStatus(profile.status),
                style: TextStyle(
                  color: profile.accentColor,
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_rounded,
                color: profile.accentColor,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _ctaForStatus(RelationProfileStatus status) {
    return switch (status) {
      RelationProfileStatus.profileOnly => '질문 시작',
      RelationProfileStatus.inProgress => '계속 답하기',
      RelationProfileStatus.mapReady => 'Map 보기',
      RelationProfileStatus.updated => '업데이트 보기',
    };
  }
}

class _ClosenessMeter extends StatelessWidget {
  const _ClosenessMeter({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = (value / 10).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '친밀도',
              style: TextStyle(
                color: _RelationMapColors.textSoft,
                fontSize: 11.6,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '$value/10',
              style: TextStyle(
                color: color,
                fontSize: 12.6,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 8, color: Colors.white.withValues(alpha: 0.09)),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});

  final RelationProfileStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RelationProfileStatus.profileOnly => '프로필',
      RelationProfileStatus.inProgress => '기록 중',
      RelationProfileStatus.mapReady => '생성 가능',
      RelationProfileStatus.updated => '업데이트',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.6,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RecentCluesSection extends StatelessWidget {
  const _RecentCluesSection();

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(16),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: _RelationMapColors.border,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '최근 관계 단서', actionLabel: '흐름'),
          SizedBox(height: 12),
          _ClueRow(
            color: _RelationMapColors.coral,
            text: '엄마와의 관계에서 인정받고 싶은 마음이 반복돼요.',
          ),
          SizedBox(height: 10),
          _ClueRow(
            color: _RelationMapColors.cyan,
            text: '민지와의 관계에서 먼저 다가가는 타이밍을 살피고 있어요.',
          ),
        ],
      ),
    );
  }
}

class _DailyQuestionCard extends StatelessWidget {
  const _DailyQuestionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(16),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: _RelationMapColors.border,
      onTap: onTap,
      child: const Row(
        children: [
          _RoundIcon(
            icon: Icons.question_answer_rounded,
            color: _RelationMapColors.violet,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 관계 질문',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '요즘 가장 마음에 남는 사람은 누구인가요?',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _RelationMapColors.textMuted,
                    fontSize: 12.2,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_rounded,
            color: _RelationMapColors.violet,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.2,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          actionLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _RelationMapColors.textMuted,
            fontSize: 11.5,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ClueRow extends StatelessWidget {
  const _ClueRow({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _RelationMapColors.textSoft,
              fontSize: 12.4,
              height: 1.38,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

abstract final class _RelationMapColors {
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const border = FiYouGlass.glassStrokeTopSmall;
  static const coral = Color(0xFFFF9F7D);
  static const cyan = Color(0xFF7DD3FC);
  static const emerald = Color(0xFF34D399);
  static const gold = Color(0xFFF7C948);
  static const violet = Color(0xFFC4B5FD);
  static const blue = Color(0xFF93C5FD);
  static const mint = Color(0xFF6EE7B7);
  static const pink = Color(0xFFF9A8D4);
  static const slate = Color(0xFF94A3B8);
}
