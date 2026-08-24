import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'cache_retry_event.dart';
import 'cache_retry_state.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/models/cache_retry_model.dart';

class ProductBloc6 extends Bloc<ProductEvent6, ProductState6> {
  final ProductRepository6 repository;

  ProductBloc6(this.repository) : super(const ProductState6()) {
    on<FetchInitialData6>(_onFetchInitial);
    on<LoadMoreProducts6>(_onLoadMore, transformer: droppable());
    on<ToggleFavorite6>(_onToggleFavorite);
    on<RefreshProducts6>(_onRefresh);
    
    // xử lý lọc và tìm kiếm,sx
    on<SearchQueryChanged>(_onSearchQueryChanged, transformer: restartable());
    on<CategoryChanged>(_onCategoryChanged);
    on<SortOrderChanged>(_onSortOrderChanged);


    on<AddProductRequested>(_onAddProduct);
    on<UpdateProductRequested>(_onUpdateProduct);
    on<DeleteProductRequested>(_onDeleteProduct);
  }

  
  //hàm tiện ích gộp chung logic gọi api lấy ds trag đầu
  Future<void> _fetchWithCurrentFilters(Emitter<ProductState6> emit) async {
    emit(state.copyWith(isInitialLoading: true, initialError: ''));
    try {
      final result = await repository.getProducts(
        0, 10,
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        sortOrder: state.sortOrder,
      );
      
      emit(state.copyWith(
        isInitialLoading: false,
        products: result.data,
        isOffline: result.isOffline,
        hasReachedMax: result.data.length < 10,
      ));
    } catch (e) {
      String errorMsg = 'Lỗi áp dụng bộ lọc.';
      if (e is ClientException) {
        errorMsg = 'Yêu cầu không hợp lệ.';
        emit(state.copyWith(isInitialLoading: false, initialError: errorMsg));
      } else if (e is NetworkException) {
        errorMsg = 'Mất kết nối mạng. Đang hiển thị dữ liệu lưu tạm.';
        
        // Khi mất mạng,lỗi local data ra 
        final cachedResult = await repository.getProducts(0, 10); 
        final cachedData = cachedResult.data; // Lấy danh sách sản phẩm từ object trả về
        
        if (cachedData.isNotEmpty) {
           emit(state.copyWith(
             isInitialLoading: false,
             products: cachedData, 
             isOffline: true,      
             initialError: '',     
           ));
        } else {
           emit(state.copyWith(isInitialLoading: false, initialError: 'Mất mạng và không có dữ liệu cũ.'));
        }
      }
    }
  }

  // x.lý s.kiện lọc
  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<ProductState6> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    
    await Future.delayed(const Duration(milliseconds: 500));
    await _fetchWithCurrentFilters(emit);
  }

  Future<void> _onCategoryChanged(CategoryChanged event, Emitter<ProductState6> emit) async {
    emit(state.copyWith(selectedCategory: event.category));
    await _fetchWithCurrentFilters(emit);
  }

  Future<void> _onSortOrderChanged(SortOrderChanged event, Emitter<ProductState6> emit) async {
    emit(state.copyWith(sortOrder: event.sortOrder));
    await _fetchWithCurrentFilters(emit);
  }

  
  Future<void> _onFetchInitial(FetchInitialData6 event, Emitter<ProductState6> emit) async {
    await _fetchWithCurrentFilters(emit);
  }

  Future<void> _onLoadMore(LoadMoreProducts6 event, Emitter<ProductState6> emit) async {
    if (state.isLoadingMore || state.hasReachedMax || state.isOffline) return;

    emit(state.copyWith(isLoadingMore: true, loadMoreError: ''));
    try {
      final result = await repository.getProducts(
        state.products.length, 10,
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        sortOrder: state.sortOrder,
      );
      emit(state.copyWith(
        isLoadingMore: false,
        products: List.of(state.products)..addAll(result.data),
        hasReachedMax: result.data.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false, 
        isOffline: true, 
        loadMoreError: 'Lỗi mạng: Không thể tải thêm dữ liệu.',
      ));
    }
  }

  Future<void> _onRefresh(RefreshProducts6 event, Emitter<ProductState6> emit) async {
    try {
      final result = await repository.getProducts(
        0, 10,
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        sortOrder: state.sortOrder,
      );
      emit(state.copyWith(
        products: result.data,
        isOffline: result.isOffline,
        hasReachedMax: result.data.length < 10,
        initialError: '', 
        loadMoreError: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        isOffline: true, 
        loadMoreError: 'Lỗi mạng: Không thể làm mới dữ liệu!',
      ));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite6 event, Emitter<ProductState6> emit) async {
   
    final targetProduct = event.product;
    final index = state.products.indexWhere((p) => p.id == targetProduct.id);
    if (index == -1) return;

    final bool currentFavStatus = targetProduct.isFavorite;
    final updatedProducts = List<Product>.from(state.products);
    
    updatedProducts[index] = Product(
      id: targetProduct.id,
      title: targetProduct.title,
      price: targetProduct.price,
      thumbnail: targetProduct.thumbnail,
      isFavorite: !currentFavStatus, 
    );
    emit(state.copyWith(products: updatedProducts));

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (state.isOffline) {
        throw Exception("Rớt mạng, không thể gửi tim lên server"); 
      }
    } catch (e) {
      final rollbackProducts = List<Product>.from(state.products);
      rollbackProducts[index] = Product(
        id: targetProduct.id,
        title: targetProduct.title,
        price: targetProduct.price,
        thumbnail: targetProduct.thumbnail,
        isFavorite: currentFavStatus, 
      );
      
      emit(state.copyWith(
        products: rollbackProducts,
        loadMoreError: 'Không có mạng nên không thể thả tim! ${DateTime.now().millisecond}',
      ));
    }
  }


  // hàm xử lý thêm
  Future<void> _onAddProduct(AddProductRequested event, Emitter<ProductState6> emit) async {
    try {
      final newProduct = await repository.addProduct(
        title: event.title, 
        price: event.price, 
        thumbnail: event.thumbnail,
      );
      // chèn sản phẩm mới lên đầu danh sách
      final updatedList = List<Product>.from(state.products)..insert(0, newProduct);
      emit(state.copyWith(products: updatedList, loadMoreError: 'Thêm sản phẩm thành công! ${DateTime.now().millisecond}'));
    } catch (e) {
      emit(state.copyWith(loadMoreError: 'Lỗi: Không thể thêm sản phẩm! ${DateTime.now().millisecond}'));
    }
  }

  // hàm x.lý update
  Future<void> _onUpdateProduct(UpdateProductRequested event, Emitter<ProductState6> emit) async {
    final index = state.products.indexWhere((p) => p.id == event.id);
    if (index == -1) return;

    // Lưu lại bản sao cũ để đề phòng rollback
    final oldProduct = state.products[index];
    final updatedList = List<Product>.from(state.products);

    // cập nhật giao diện trước
    updatedList[index] = Product(
      id: oldProduct.id,
      title: event.title,
      price: event.price,
      thumbnail: oldProduct.thumbnail,
      isFavorite: oldProduct.isFavorite,
    );
    emit(state.copyWith(products: updatedList));

    try {
      await repository.updateProduct(id: event.id, title: event.title, price: event.price);
      emit(state.copyWith(loadMoreError: 'Cập nhật thành công! ${DateTime.now().millisecond}'));
    } catch (e) {
      // rollback nếu api lỗi
      updatedList[index] = oldProduct;
      emit(state.copyWith(
        products: updatedList,
        loadMoreError: 'Lỗi mạng: Không thể cập nhật! ${DateTime.now().millisecond}',
      ));
    }
  }

  // hàm xóa
  Future<void> _onDeleteProduct(DeleteProductRequested event, Emitter<ProductState6> emit) async {
    final index = state.products.indexWhere((p) => p.id == event.id);
    if (index == -1) return;

    final deletedProduct = state.products[index];
    final updatedList = List<Product>.from(state.products)..removeAt(index);

    // xóa tạm thời khỏi UI
    emit(state.copyWith(products: updatedList));

    try {
      await repository.deleteProduct(event.id);
      emit(state.copyWith(loadMoreError: 'Xóa sản phẩm thành công! ${DateTime.now().millisecond}'));
    } catch (e) {
      // Rolrback: thêm lại sản phẩm vào vị trí cũ nếu xóa thất bại
      updatedList.insert(index, deletedProduct);
      emit(state.copyWith(
        products: updatedList,
        loadMoreError: 'Lỗi mạng: Không thể xóa sản phẩm! ${DateTime.now().millisecond}',
      ));
    }
  }


}