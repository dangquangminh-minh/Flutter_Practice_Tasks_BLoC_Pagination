import 'package:flutter_bloc/flutter_bloc.dart';


import 'post_event.dart';
import 'post_state.dart';
import '../../repositories/post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> { // nhận event , nhả ra state
  final PostRepository repository;

  PostBloc(this.repository) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    // 1. Vừa bắt đầu tải, phát ra state Loading
    emit(PostLoading());

    try {
      // 2. Gọi Repository để lấy dữ liệu
      final posts = await repository.fetchPosts();

      // 3. Kiểm tra rỗng và phát ra state tương ứng
      if (posts.isEmpty) {
        emit(PostEmpty());
      } else {
        emit(PostSuccess(posts));
      }
    } catch (e) {
      // 4. Nếu có lỗi, phát ra state Failure
      emit(PostFailure(e.toString()));
    }
  }
}