import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../repositories/repository_providers.dart';

const androidOneTimeProductIds = <String>{
  'fiyou_star_100',
  'fiyou_star_300',
  'fiyou_star_700',
  'fiyou_star_1500',
  'fiyou_report_umap_deep_1',
  'fiyou_report_signature_deep_1',
  'fiyou_report_relation_1',
  'fiyou_report_past_self_1',
};

const androidSubscriptionProductIds = <String>{
  'fiyou_plus',
};

const androidBillingProductIds = <String>{
  ...androidOneTimeProductIds,
  ...androidSubscriptionProductIds,
};

bool isAndroidConsumableProduct(String productId) =>
    androidOneTimeProductIds.contains(productId);

class BillingState {
  const BillingState({
    this.available = false,
    this.loading = false,
    this.verifying = false,
    this.products = const [],
    this.statusMessage,
    this.errorMessage,
  });

  final bool available;
  final bool loading;
  final bool verifying;
  final List<ProductDetails> products;
  final String? statusMessage;
  final String? errorMessage;

  BillingState copyWith({
    bool? available,
    bool? loading,
    bool? verifying,
    List<ProductDetails>? products,
    String? statusMessage,
    String? errorMessage,
    bool clearStatus = false,
    bool clearError = false,
  }) {
    return BillingState(
      available: available ?? this.available,
      loading: loading ?? this.loading,
      verifying: verifying ?? this.verifying,
      products: products ?? this.products,
      statusMessage: clearStatus ? null : statusMessage ?? this.statusMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BillingController extends Notifier<BillingState> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  BillingState build() {
    ref.onDispose(() => _subscription?.cancel());
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {
        state = state.copyWith(
          errorMessage: '결제 상태를 확인하지 못했어요.',
          clearStatus: true,
        );
      },
    );
    return const BillingState();
  }

  Future<void> loadProducts(Set<String> productIds) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      clearStatus: true,
    );
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      state = state.copyWith(
        available: false,
        loading: false,
        errorMessage: 'Google Play 결제를 사용할 수 없어요.',
      );
      return;
    }
    final response = await InAppPurchase.instance.queryProductDetails(productIds);
    state = state.copyWith(
      available: true,
      loading: false,
      products: response.productDetails,
      errorMessage: response.error?.message,
    );
  }

  Future<void> buy(ProductDetails product) async {
    state = state.copyWith(
      statusMessage: 'Google Play 결제 창을 여는 중이에요.',
      clearError: true,
    );
    final param = PurchaseParam(productDetails: product);
    if (isAndroidConsumableProduct(product.id)) {
      await InAppPurchase.instance.buyConsumable(purchaseParam: param);
    } else {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(
            statusMessage: '결제가 대기 중이에요. 완료되면 다시 반영할게요.',
            clearError: true,
          );
          break;
        case PurchaseStatus.canceled:
          state = state.copyWith(
            statusMessage: '결제를 취소했어요.',
            clearError: true,
          );
          break;
        case PurchaseStatus.error:
          state = state.copyWith(
            errorMessage: purchase.error?.message ?? '결제에 실패했어요.',
            clearStatus: true,
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndComplete(purchase);
          break;
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchase) async {
    state = state.copyWith(
      verifying: true,
      statusMessage: '구매를 확인하는 중이에요.',
      clearError: true,
    );
    try {
      await ref.read(selfDiscoveryRepositoryProvider).submitPurchaseToken(
            productId: purchase.productID,
            purchaseToken: purchase.verificationData.serverVerificationData,
            source: purchase.verificationData.source,
          );
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      state = state.copyWith(
        verifying: false,
        statusMessage: '구매가 반영되었어요.',
        clearError: true,
      );
      ref.invalidate(todaySummaryProvider);
      ref.invalidate(storeProductsProvider);
      ref.invalidate(reportsProvider);
    } catch (_) {
      state = state.copyWith(
        verifying: false,
        errorMessage: '구매 확인에 실패했어요. 잠시 후 다시 확인해주세요.',
        clearStatus: true,
      );
    }
  }
}

final billingControllerProvider = NotifierProvider<BillingController, BillingState>(
  BillingController.new,
);
