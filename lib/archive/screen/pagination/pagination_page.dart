import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/post_repository.dart';
import 'pagination_bloc.dart';
import 'pagination_event.dart';
import 'pagination_state.dart';
// bổ sung đổi stateless thành ful để làm thêm phần bonus task 2
class Bai2 extends StatefulWidget { 
  const Bai2({super.key});
  @override
  State<Bai2> createState() => _Bai2State();
}


class _Bai2State extends State<Bai2> {

// theo dõi ng dùng cuộn màn hình để hiển thị nút kéo lên đầu trang
final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 400) {
        if (!_showBackToTopButton) setState(() => _showBackToTopButton = true);
      } else {
        if (_showBackToTopButton) setState(() => _showBackToTopButton = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginationBloc(PostRepository())..add(FetchInitialData()),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<PaginationBloc, PaginationState>(
             builder: (context, state) => Text('Phân trang (${state.posts.length} bài)'),
          ),
        ),
        // hiện nút cuộn 
        floatingActionButton: _showBackToTopButton
    ?     FloatingActionButton(
         onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
         child: const Icon(Icons.arrow_upward),
         )
         : null,

        body: SafeArea(
          child: BlocBuilder<PaginationBloc, PaginationState>(
            builder: (context, state) {
              if (state.isInitialLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state.errorMessage.isNotEmpty && state.posts.isEmpty) {
                return Center(child: Text(state.errorMessage));
              }

              return ListView.builder(
                controller: _scrollController, // bổ sung để đo độ cuộn 
                // Cộng 1 để chừa chỗ cho Widget dưới cùng (Nút Xem thêm / Loading / Thông báo)
                itemCount: state.posts.length + 1,
                itemBuilder: (context, index) {
                  // Nếu cuộn đến cuối cùng
                  if (index == state.posts.length) {
                    if (state.hasReachedMax) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('Đã hết dữ liệu')), // Thông báo khi hết dữ liệu[cite: 1]
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        // Vô hiệu hóa nút khi đang tải thêm bằng cách set onPressed = null[cite: 1]
                        onPressed: state.isLoadingMore 
                            ? null 
                            : () => context.read<PaginationBloc>().add(LoadMoreData()),
                        child: state.isLoadingMore 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('Xem thêm'),
                      ),
                    );
                  }

                  // Render bài viết bình thường
                  final post = state.posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}