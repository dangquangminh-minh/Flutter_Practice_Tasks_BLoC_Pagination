import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/post_repository.dart';
import 'event.dart';
import 'state.dart';

class PaginationBloc extends Bloc<PaginationEvent, PaginationState> {
  final PostRepository repository;
  final int pageSize = 10;

  PaginationBloc(this.repository) : super(const PaginationState()) {
    on<FetchInitialData>(_onFetchInitialData);
    on<LoadMoreData>(_onLoadMoreData);
  }
  // tải ds lần đầu 
  Future<void> _onFetchInitialData(FetchInitialData event, Emitter<PaginationState> emit) async {
    emit(state.copyWith(isInitialLoading: true, errorMessage: ''));
    try {
      final posts = await repository.fetchPosts(page: 1, limit: pageSize);
      emit(state.copyWith(
        posts: posts,
        currentPage: 1,
        isInitialLoading: false,
        hasReachedMax: posts.length < pageSize, // Hết dữ liệu nếu số phần tử < pageSize[cite: 1]
      ));
    } catch (e) {
      emit(state.copyWith(isInitialLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreData(LoadMoreData event, Emitter<PaginationState> emit) async {
    // Chặn gọi trùng: Nếu đang tải thêm HOẶC đã hết dữ liệu thì return ngay lập tức[cite: 1]
    // chặn ng dùng spam nút "xem thêm" để tránh gọi api nhiều lần cùng lúc
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    try {
      final nextPage = state.currentPage + 1;
      final newPosts = await repository.fetchPosts(page: nextPage, limit: pageSize);
      
      emit(state.copyWith(
        posts: List.of(state.posts)..addAll(newPosts), // Nối dữ liệu mới vào cuối danh sách cũ[cite: 1]
        currentPage: nextPage,
        isLoadingMore: false,
        hasReachedMax: newPosts.length < pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.toString()));
    }
  }
}