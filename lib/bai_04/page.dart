import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/repositories.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

//lớp 1 khởi tạo bloc
class Bai4 extends StatelessWidget {
  const Bai4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(SearchRepository()),
      child: const Bai4View(),
    );
  }
}

//lớp 2 : giao diện và thanh cuộn
class Bai4View extends StatefulWidget {
  const Bai4View({Key? key}) : super(key: key);

  @override
  State<Bai4View> createState() => _Bai4ViewState();
}

class _Bai4ViewState extends State<Bai4View> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gắn cảm biến cuộn cách đáy 200px để tải thêm
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (maxScroll - currentScroll <= 200) {
        context.read<SearchBloc>().add(LoadMoreSearchResults());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // bonus: hightlight chữ mà ng dùng tìm kiếm
  Widget _buildHighlightedTitle(String text, String query, TextStyle normalStyle, TextStyle highlightStyle) {
    if (query.isEmpty) {
      return Text(text, style: normalStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: normalStyle);
    }

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch = lowerText.indexOf(lowerQuery, start);

    while (indexOfMatch != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch), style: normalStyle));
      }
      final matchedText = text.substring(indexOfMatch, indexOfMatch + query.length);
      spans.add(TextSpan(text: matchedText, style: highlightStyle));
      start = indexOfMatch + query.length;
      indexOfMatch = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: normalStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm & Phân trang (Bài 4)'),
      ),
      body: Column(
        children: [
          // Ô nhập từ khóa tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Bắn event gõ phím -> Sẽ được Debounce 500ms ở BLoC xử lý
                context.read<SearchBloc>().add(SearchKeywordChanged(value));
              },
              decoration: InputDecoration(
                labelText: 'Nhập từ khóa tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchBloc>().add(SearchKeywordChanged(''));
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // Khu vực hiển thị kết quả
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                // trạng thái đang tải lần đầu
                if (state.isInitialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // trạng thái lỗi
                if (state.errorMessage.isNotEmpty && state.posts.isEmpty) {
                  return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
                }

                // trạng thái chưa nhập gì hoặc không tìm thấy
                if (state.keyword.isEmpty) {
                  return const Center(child: Text('Hãy nhập từ khóa để bắt đầu tìm kiếm'));
                }

                if (state.posts.isEmpty) {
                  return const Center(child: Text('Không tìm thấy kết quả phù hợp'));
                }

                // hiển thị danh sách kết quả
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.posts.length) {
                      if (state.hasReachedMax) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Đã hiển thị tất cả kết quả')),
                        );
                      }
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
                      return const SizedBox.shrink();
                    }

                    final post = state.posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        // Áp dụng Highlight từ khóa cho Tiêu đề
                        title: _buildHighlightedTitle(
                          post.title,
                          state.keyword,
                          const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, backgroundColor: Colors.yellowAccent),
                        ),
                        subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}