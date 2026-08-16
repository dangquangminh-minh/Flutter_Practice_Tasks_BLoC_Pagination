import '../models/model_6.dart';

class ProductState6 {
  final List<Product> products;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String initialError;
  final String loadMoreError;
  final bool isOffline; // hiện nhãn thông báo offline khi rớt mạng

  const ProductState6({
    this.products = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.initialError = '',
    this.loadMoreError = '',
    this.isOffline = false,
  });

  ProductState6 copyWith({
    List<Product>? products,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? initialError,
    String? loadMoreError,
    bool? isOffline,
  }) {
    return ProductState6(
      products: products ?? this.products,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initialError: initialError ?? this.initialError,
      loadMoreError: loadMoreError ?? this.loadMoreError,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}