import '../../domain/models/cache_retry_model.dart';

class ProductState6 {
  final List<Product> products;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String initialError;
  final String loadMoreError;
  final bool isOffline; 
  
  // state tìm ,lọc,sx
  final String searchQuery;
  final String? selectedCategory;
  final String? sortOrder; // asc ,desc
  final List<String> categories;
  // constructor
  const ProductState6({
    this.products = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.initialError = '',
    this.loadMoreError = '',
    this.isOffline = false,
    
    // khởi tạo mặc định
    this.searchQuery = '',
    this.selectedCategory,
    this.sortOrder,
    this.categories = const [],
  });

  ProductState6 copyWith({
    List<Product>? products,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? initialError,
    String? loadMoreError,
    bool? isOffline,
    
    // khai báo kiểu dữ liệu truyền vào
    String? searchQuery,
    String? selectedCategory,
    String? sortOrder,
    List<String>? categories,
  }) {
    return ProductState6(
      products: products ?? this.products,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initialError: initialError ?? this.initialError,
      loadMoreError: loadMoreError ?? this.loadMoreError,
      isOffline: isOffline ?? this.isOffline,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOrder: sortOrder ?? this.sortOrder,
      categories: categories ?? this.categories,
    );
  }
}