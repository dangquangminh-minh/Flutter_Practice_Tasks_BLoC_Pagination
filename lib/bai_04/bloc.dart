import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';
import 'event.dart';
import 'state.dart';
import '../repositories/repositories.dart';


//bắt chờ 500ms , nếu gõ nx thì nó hủy cái cũ tính lại cái mới
EventTransformer<Event> debounceRestartable<Event>() {
  return (events, mapper) {
    return restartable<Event>().call(
      events.debounceTime(const Duration(milliseconds: 500)),
      mapper,
    );
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;

  SearchBloc(this.repository) : super(const SearchState()) {
    
    
    on<SearchKeywordChanged>(
      _onKeywordChanged,
      transformer: debounceRestartable(), 
    );

    //chống spam api
    on<LoadMoreSearchResults>(
      _onLoadMore,
      transformer: droppable(),
    );
  }

  Future<void> _onKeywordChanged(SearchKeywordChanged event, Emitter<SearchState> emit) async {
    final keyword = event.keyword.trim();

    //if thanh tìm kiếm k có j thì xóa kq
    if (keyword.isEmpty) {
      emit(state.copyWith(posts: [], keyword: '', hasReachedMax: false, isInitialLoading: false));
      return;
    }

    //khi đổi từ khóa thì reset lại danh sách và trạng thái phân trang
    emit(state.copyWith(
      isInitialLoading: true,
      keyword: keyword, // Lưu từ khóa mới vào State
      posts: [],        // Xóa sạch danh sách cũ
      hasReachedMax: false,
      errorMessage: '',
    ));

    try {
      // tìm mới thì truyền skip = 0
      final newPosts = await repository.searchPosts(keyword: keyword, skip: 0);
      emit(state.copyWith(
        isInitialLoading: false,
        posts: newPosts,
        hasReachedMax: newPosts.isEmpty || newPosts.length < 10,
      ));
    } catch (e) {
      emit(state.copyWith(isInitialLoading: false, errorMessage: 'Lỗi tải dữ liệu. Vui lòng thử lại!'));
    }
  }

  Future<void> _onLoadMore(LoadMoreSearchResults event, Emitter<SearchState> emit) async {
    // Không tải nếu đang tải dở, hết dữ liệu, hoặc chưa gõ chữ nào
    if (state.isLoadingMore || state.hasReachedMax || state.keyword.isEmpty) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));

    try {
      // Logic Skip : Số bài cần bỏ qua đúng bằng tổng số bài đang có trên màn hình
      final skip = state.posts.length; 
      
      // Gọi API với cái keyword đang lưu trong State
      final morePosts = await repository.searchPosts(keyword: state.keyword, skip: skip);

      emit(state.copyWith(
        isLoadingMore: false,
        posts: List.of(state.posts)..addAll(morePosts), // Nối bài mới vào đuôi bài cũ
        hasReachedMax: morePosts.isEmpty || morePosts.length < 10,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: 'Lỗi tải thêm dữ liệu.'));
    }
  }
}