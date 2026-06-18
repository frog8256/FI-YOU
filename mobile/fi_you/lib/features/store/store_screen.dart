import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/billing/billing_service.dart';
import '../../data/models/fiyou_models.dart';
import '../../data/repositories/repository_providers.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(billingControllerProvider.notifier).loadProducts(androidBillingProductIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(storeProductsProvider);
    final billing = ref.watch(billingControllerProvider);

    return products.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: '상품 정보를 불러오지 못했어요',
        body: 'Google Play 상품 연결을 확인한 뒤 다시 시도해 주세요.',
        actionLabel: '다시 시도',
        onAction: () {
          ref.invalidate(storeProductsProvider);
          ref.read(billingControllerProvider.notifier).loadProducts(androidBillingProductIds);
        },
      ),
      data: (items) => FiYouPage(
        children: [
          const FiYouHeader(
            overline: 'Store',
            title: '더 깊은 탐구가\n필요할 때만',
            subtitle: '기본 질문과 Diary는 FI-YOU의 중심입니다. Star와 리포트는 추가로 보고 싶은 흐름을 여는 선택지예요.',
          ),
          if (billing.loading || billing.verifying)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: GlassCard(child: Text('Google Play와 연결하는 중이에요.')),
            ),
          if (billing.statusMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(child: Text(billing.statusMessage!)),
            ),
          if (billing.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(child: Text(billing.errorMessage!)),
            ),
          if (items.isEmpty)
            const GlassCard(child: Text('아직 표시할 상품이 없어요.'))
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(
                  item: item,
                  billing: billing,
                  onBuy: () => _buy(item),
                ),
              ),
          const SizedBox(height: 8),
          Text(
            'Android 앱 내부 결제는 Google Play Billing으로 처리됩니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FiYouColors.muted),
          ),
        ],
      ),
    );
  }

  Future<void> _buy(StoreProduct item) async {
    final productDetails = ref.read(billingControllerProvider).products;
    final index = productDetails.indexWhere((product) => product.id == item.id);
    if (index == -1) {
      await ref.read(billingControllerProvider.notifier).loadProducts(androidBillingProductIds);
      return;
    }
    await ref.read(billingControllerProvider.notifier).buy(productDetails[index]);
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.billing,
    required this.onBuy,
  });

  final StoreProduct item;
  final BillingState billing;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final playDetails = _playDetailsFor(item.id);
    final price = playDetails?.price ?? item.priceLabel;
    return GlassCard(
      emphasis: item.id == 'fiyou_plus',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: FiYouColors.gold),
              const SizedBox(width: 10),
              Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          FiYouGradientButton(
            label: '${_ctaFor(item)} · $price',
            icon: Icons.lock_open_outlined,
            onPressed: billing.loading || billing.verifying ? null : onBuy,
          ),
        ],
      ),
    );
  }

  ProductDetails? _playDetailsFor(String productId) {
    final index = billing.products.indexWhere((product) => product.id == productId);
    return index == -1 ? null : billing.products[index];
  }

  String _ctaFor(StoreProduct item) {
    if (item.id == 'fiyou_plus') return 'FI-YOU Plus 보기';
    if (item.kind == 'consumable' && item.starAmount != null) {
      return 'Star 충전';
    }
    return '확장 리포트 열기';
  }
}
