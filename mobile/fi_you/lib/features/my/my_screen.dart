import 'package:fi_you/features/my/my_models.dart';
import 'package:fi_you/features/my/my_theme.dart';
import 'package:fi_you/features/my/settings_screen.dart';
import 'package:fi_you/features/my/store_screen.dart';
import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({
    this.profile = const MyProfileData(),
    this.insights = myDefaultInsights,
    this.onOpenStore,
    this.onOpenSettings,
    super.key,
  });

  final MyProfileData profile;
  final List<MyInsightData> insights;
  final VoidCallback? onOpenStore;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return MyPageScaffold(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        children: [
          const _Header(),
          const SizedBox(height: 20),
          _ProfileCard(profile: profile, onStarTap: () => _openStore(context)),
          const SizedBox(height: 24),
          const MySectionTitle(
            title: '탐험의 흐름',
            subtitle: '지금까지의 기록에서 보이는 자기탐색의 흔적입니다.',
          ),
          const SizedBox(height: 12),
          _InsightList(insights: insights),
          const SizedBox(height: 22),
          _SettingsButton(onTap: () => _openSettings(context)),
        ],
      ),
    );
  }

  void _openStore(BuildContext context) {
    if (onOpenStore != null) {
      onOpenStore!();
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => StoreScreen(profile: profile)),
    );
  }

  void _openSettings(BuildContext context) {
    if (onOpenSettings != null) {
      onOpenSettings!();
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => SettingsScreen(profile: profile)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.person_rounded, color: MyColors.primarySoft, size: 23),
        const SizedBox(width: 10),
        const Text(
          'My',
          style: TextStyle(
            color: MyColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onStarTap});

  final MyProfileData profile;
  final VoidCallback onStarTap;

  @override
  Widget build(BuildContext context) {
    return MySurface(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      radius: FiYouGlass.glassRadiusCard,
      borderColor: FiYouGlass.glassStrokeTop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.profileLine,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MyColors.primarySoft,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${profile.name} 님',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyColors.text,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _ProfileRecordStats(),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricBox(label: 'Level', value: '${profile.level}'),
              const SizedBox(width: 10),
              _MetricBox(label: 'Star', value: '${profile.starBalance}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileRecordStats extends StatelessWidget {
  const _ProfileRecordStats();

  @override
  Widget build(BuildContext context) {
    const stats = <({String label, String value})>[
      (label: '탐구시작', value: '00일'),
      (label: '총 출석', value: '00일'),
      (label: '연속출석', value: '00일'),
      (label: 'Diary', value: '00개'),
      (label: '연속작성', value: '00개'),
    ];

    return Row(
      children: [
        for (var index = 0; index < stats.length; index++) ...[
          Expanded(child: _ProfileRecordStat(item: stats[index])),
          if (index == 2) const _ProfileStatsDivider(),
          if (index != stats.length - 1 && index != 2) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _ProfileStatsDivider extends StatelessWidget {
  const _ProfileStatsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: FiYouGlass.glassStrokeBottom,
    );
  }
}

class _ProfileRecordStat extends StatelessWidget {
  const _ProfileRecordStat({required this.item});

  final ({String label, String value}) item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            item.label,
            maxLines: 1,
            style: const TextStyle(
              color: MyColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            item.value,
            maxLines: 1,
            style: const TextStyle(
              color: MyColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tint = label == 'Star' ? MyColors.gold : MyColors.primarySoft;

    return Expanded(
      child: SizedBox(
        height: 42,
        child: MySurface(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          radius: FiYouGlass.glassRadiusSmall,
          borderColor: tint,
          v5Preset: FiYouGlassV5Preset.cta,
          child: SizedBox.expand(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: MyColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: MyColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightList extends StatelessWidget {
  const _InsightList({required this.insights});

  final List<MyInsightData> insights;

  @override
  Widget build(BuildContext context) {
    return MySurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      radius: FiYouGlass.glassRadiusCard,
      child: Column(
        children: [
          for (var index = 0; index < insights.length; index++) ...[
            _InsightRow(insight: insights[index]),
            if (index != insights.length - 1)
              Divider(
                height: 1,
                color: FiYouGlass.glassStrokeBottom,
                indent: 50,
              ),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final MyInsightData insight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FiYouIconTile(
            color: insight.color,
            size: FiYouControlTokens.iconTileList,
            child: Icon(
              insight.icon,
              color: insight.color,
              size: FiYouControlTokens.iconTileListIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    color: MyColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: MyColors.textSoft,
                    fontSize: 12.3,
                    height: 1.42,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSettingsActionButton(
      label: 'Settings',
      icon: const Icon(Icons.settings_outlined),
      onPressed: onTap,
    );
  }
}
