import 'package:equatable/equatable.dart';
import '../../models/post_model.dart';

class PaginationState extends Equatable {
  final List<Post> posts; // giữ lại toàn bộ ds trang đang có
  final int currentPage; // ghi nhớ người dùng đang ở trag mấy để api goi trang tiếp theo
  final bool isLoadingMore; // trạng thái load khi cuộn xuống
  final bool hasReachedMax; // chặn "xem thêm"
  final String errorMessage;
  final bool isInitialLoading; // Dùng để phân biệt loading lần đầu và tải thêm

  const PaginationState({
    this.posts = const [],
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.isInitialLoading = false,
  });

  // Hàm copyWith giúp giữ nguyên dữ liệu cũ, chỉ cập nhật những biến mới khi ng dùng chọn "xem thêm"
  PaginationState copyWith({
    List<Post>? posts,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    bool? isInitialLoading,
  }) {
    return PaginationState(
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        currentPage,
        isLoadingMore,
        hasReachedMax,
        errorMessage,
        isInitialLoading,
      ];
}