import '../models/model.dart';

class SearchState {
  final List<Post> posts; // giữ lại toàn bộ ds trang đang có
  final bool isLoadingMore; // trạng thái load khi cuộn xuống   
  final bool hasReachedMax;   // chặn "xem thêm" 
  final String errorMessage;
  final bool isInitialLoading; // Dùng để phân biệt loading lần đầu và tải thêm


  final String keyword; // state mới để lưu từ khóa ng dùng tìm kiếm 

  const SearchState({
    this.posts = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.keyword = '',
  });

  SearchState copyWith({
    List<Post>? posts,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    String? keyword,
  }) {
    return SearchState(
      posts: posts ?? this.posts,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      keyword: keyword ?? this.keyword,
    );
  }
}