import '../../models/product_filter_model.dart';

class ProductState {
  final List<Product> products;
  final List<String> categories; 
  final QueryModel query;        // Lưu trữ bộ lọc hiện tại
  
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  
 // lỗi khi trag đầu chưa load ds lên mà vd mất mạng thì báo cái state này ra để thông báo lỗi
  final String initialError;     // Lỗi khi tải lần đầu hoặc khi Refresh

  // tách 2 cái state lỗi này ra là để 
  // vd: nếu dùng chung 1 biến state trên, khi mình kéo tới trang 20 sp thì lỗi , 
  // thì nó sẽ load lại từ đầu thay vì trang ng dùng hiện tại đag xem nên mới tách ra 2 lỗi riêng
  final String loadMoreError;    // Lỗi khi đang cuộn xuống tải thêm

  const ProductState({
    this.products = const [],
    this.categories = const [],
    this.query = const QueryModel(), // Mặc định limit=10, skip=0
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.initialError = '',
    this.loadMoreError = '',
  });

  ProductState copyWith({
    List<Product>? products,
    List<String>? categories,
    QueryModel? query,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? initialError,
    String? loadMoreError,
  }) {
    return ProductState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initialError: initialError ?? this.initialError,
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}