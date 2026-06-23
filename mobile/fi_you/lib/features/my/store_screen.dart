import 'package:fi_you/features/my/my_models.dart';
import 'package:fi_you/features/my/my_theme.dart';
import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({
    this.profile = const MyProfileData(),
    this.packages = myDefaultPackages,
    this.history = myDefaultHistory,
    this.onPackageTap,
    super.key,
  });

  final MyProfileData profile;
  final List<StorePackageData> packages;
  final List<StarHistoryData> history;
  final ValueChanged<StorePackageData>? onPackageTap;

  @override
  Widget build(BuildContext context) {
    return MyPageScaffold(
      appBar: myPlainAppBar(context, 'Store'),
      bottomPadding: 0,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          MySurface(
            padding: const EdgeInsets.all(20),
            borderColor: FiYouGlass.glassStrokeTop,
            radius: FiYouGlass.glassRadiusCard,
            child: Row(
              children: [
                const _GoldLogoBadge(size: 58, padding: 8),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Star 잔액',
                        style: TextStyle(
                          color: MyColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.starBalance} Star',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MyColors.gold,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const MySectionTitle(
            title: '구매 패키지',
            subtitle: 'Google Play Billing 연결 전 mock UI입니다.',
          ),
          const SizedBox(height: 12),
          for (final package in packages) ...[
            _PackageTile(
              package: package,
              onTap: () {
                if (onPackageTap != null) {
                  onPackageTap!(package);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google Play Billing 연결 전 mock 패키지입니다.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          const MySectionTitle(title: '사용 내역', subtitle: '최근 Star 흐름'),
          const SizedBox(height: 12),
          MySurface(
            padding: EdgeInsets.zero,
            radius: 22,
            v5Preset: FiYouGlassV5Preset.medium,
            child: Column(
              children: [
                for (var index = 0; index < history.length; index++) ...[
                  _HistoryTile(item: history[index]),
                  if (index != history.length - 1)
                    Divider(
                      height: 1,
                      color: FiYouGlass.glassStrokeBottom,
                      indent: 52,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldLogoBadge extends StatelessWidget {
  const _GoldLogoBadge({required this.size, required this.padding});

  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FiYouGlassSurface(
        padding: EdgeInsets.all(padding),
        radius: size,
        v5Preset: FiYouGlassV5Preset.small,
        child: Image.asset('assets/images/Logo_gold.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, this.onTap});

  final StorePackageData package;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MySurface(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: 22,
      v5Preset: FiYouGlassV5Preset.medium,
      child: Row(
        children: [
          const _GoldLogoBadge(size: 42, padding: 7),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  package.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyColors.textSoft,
                    fontSize: 12,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${package.stars} Star',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  package.priceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: MyColors.textSoft,
                    fontSize: 12,
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final StarHistoryData item;

  @override
  Widget build(BuildContext context) {
    final isGain = item.amount > 0;

    return ListTile(
      minLeadingWidth: 24,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        isGain
            ? Icons.add_circle_outline_rounded
            : Icons.remove_circle_outline_rounded,
        color: isGain ? MyColors.gold : MyColors.primarySoft,
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: MyColors.textSoft,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        item.dateLabel,
        style: const TextStyle(
          color: MyColors.textSoft,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 86),
        child: Text(
          '${isGain ? '+' : ''}${item.amount} Star',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: isGain ? MyColors.gold : MyColors.primarySoft,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
