import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/post_repository.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';


// --- LỚP 1: CẤP VỐN (Khởi tạo BLoC) ---
class Bai3 extends StatelessWidget {
  const Bai3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginationBloc(PostRepository())..add(FetchInitialData()),
      child: const Bai3View(), // Đẩy xuống cho lớp View bên dưới xài
    );
  }
}


// bổ sung đổi stateless thành ful để làm thêm phần bonus task 2
// --- LỚP 2: XÀI VỐN (Giao diện + Cảm biến cuộn) ---
class Bai3View extends StatefulWidget {
  const Bai3View({Key? key}) : super(key: key);

  @override
  State<Bai3View> createState() => _Bai3ViewState();
}

class _Bai3ViewState extends State<Bai3View> {

// theo dõi ng dùng cuộn màn hình để hiển thị nút kéo lên đầu trang
final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      //Tính toán vị trí hiện tại và tổng chiều dài danh sách
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // tự động tải thêm ds khi kéo xuống còn 200px
      if (maxScroll - currentScroll <= 200) {
        // nahr event ra để lấy ds 
        context.read<PaginationBloc>().add(LoadMoreData());
      }
      // ẩn hiện nút  cuộn lên đầu trang của bài 2
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
      // xóa blocprovider vì tạo ở khúc trên rồi
      
      return Scaffold(
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
                // 1. NẾU LÀ CÁI ITEM CUỐI CÙNG (Dùng để hiển thị trạng thái)
                if (index == state.posts.length) {
                  if (state.hasReachedMax) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Đã hết dữ liệu')),
                    );
                  }

                    //xóa cái nút 'xem thêm' của bài 2 thành load
                    // và chỉ xoay khi đang tải chứ không có xoay ảo
                    if (state.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 24, 
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    } 
                    return const SizedBox.shrink(); // trả về để sửa lỗi đổ màn hình 
                
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
    );
  }
}