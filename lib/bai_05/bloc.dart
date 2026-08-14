import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'event.dart';
import 'state.dart';
import '../repositories/repository_5.dart';
import '../models/model_5.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(const ProductState()) {
    on<FetchInitialData>(_onFetchInitialData);
    
    // Khi thay đổi bộ lọc, dùng restartable để hủy API cũ đang chạy dở (bài 4)
    // chống lỗi response cũ ghi đè
    on<FilterChanged>(_onFilterChanged, transformer: restartable());
    
    // Khi tải thêm, dùng droppable chặn spam api khi ng dùng liên tục kéo tải thêm (bài 3)
    on<LoadMoreProducts>(_onLoadMore, transformer: droppable());
    
    on<RefreshProducts>(_onRefresh, transformer: droppable());
  }

  //load sp vs danh mục
  Future<void> _onFetchInitialData(FetchInitialData event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isInitialLoading: true, initialError: ''));
    try {
      // tải song song cả danh mục và sản phẩm trang 1 để tiết kiệm thời gian
      final results = await Future.wait([ // dùng future await để bắt 2 con chạy cùng lúc
        repository.fetchCategories(),
        repository.fetchProducts(state.query),
      ]);
      
      final categories = results[0] as List<String>;
      final products = results[1] as List<Product>;

      emit(state.copyWith(
        isInitialLoading: false,
        categories: categories,
        products: products,
        hasReachedMax: products.length < state.query.limit,
      ));
    } catch (e) {
      emit(state.copyWith(isInitialLoading: false, initialError: 'Không thể tải dữ liệu ban đầu.')); // và nếu lỗi thì ném ra initiaError
    }
  }

  Future<void> _onFilterChanged(FilterChanged event, Emitter<ProductState> emit) async {
    // khi đổi lọc,sxếp,tìm kiếm thì reset lại phân trang (skip=0 )
    // để tránh kq bị sai or rỗng  
    final resetQuery = event.newQuery.copyWith(skip: 0);

    emit(state.copyWith(
      isInitialLoading: true,
      query: resetQuery, // Lưu bộ lọc mới
      products: [],        // xóa danh sách cũ để tìm dl mới
      hasReachedMax: false,
      initialError: '',
    ));

    try {
      final newProducts = await repository.fetchProducts(resetQuery);
      emit(state.copyWith(
        isInitialLoading: false,
        products: newProducts,
        hasReachedMax: newProducts.length < resetQuery.limit,
      ));
    } catch (e) {
      emit(state.copyWith(isInitialLoading: false, initialError: 'Lỗi tải dữ liệu. Vui lòng thử lại.'));
    }
  }

  Future<void> _onLoadMore(LoadMoreProducts event, Emitter<ProductState> emit) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true, loadMoreError: ''));

    try {
      // Cập nhật skip = số sản phẩm hiện tại
      final nextQuery = state.query.copyWith(skip: state.products.length);
      final moreProducts = await repository.fetchProducts(nextQuery);

      emit(state.copyWith(
        isLoadingMore: false,
        query: nextQuery, // Cập nhật lại query với skip mới
        products: List.of(state.products)..addAll(moreProducts),
        hasReachedMax: moreProducts.length < state.query.limit,
      ));
    } catch (e) {
      // nếu lỗi thì vẫn giữ nguyên ds hiện tải 
      emit(state.copyWith(isLoadingMore: false, loadMoreError: 'Lỗi kết nối khi tải thêm.'));
    }
  }

  Future<void> _onRefresh(RefreshProducts event, Emitter<ProductState> emit) async {
    //khi kéo lên lm mới thì giữ nguyên bộ lọc/sx/tìm kiếm , chỉ đưa skip về 0
    final refreshQuery = state.query.copyWith(skip: 0);

    // không gán product: [] giúp người dùng vẫn thấy list cũ trong lúc tải
    try {
      final freshProducts = await repository.fetchProducts(refreshQuery);
      emit(state.copyWith(
        query: refreshQuery,
        products: freshProducts,
        hasReachedMax: freshProducts.length < refreshQuery.limit,
        initialError: '', // Xóa lỗi cũ nếu có
      ));
    } catch (e) {
      // Nếu refresh lỗi, vẫn giữ nguyên danh sách hiện tại
      emit(state.copyWith(initialError: 'Làm mới thất bại, vui lòng kiểm tra mạng.'));
    }
  }
}