import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'post_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../repositories/post_repository.dart'; 

class Bai1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(PostRepository())..add(FetchPosts()),
      child: Scaffold(
        appBar: AppBar(title: Text('Danh sách bài viết')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostInitial || state is PostLoading) {
                  return Center(child: CircularProgressIndicator()); // Trạng thái Loading
                } 
                
                else if (state is PostFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.errorMessage, textAlign: TextAlign.center),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Gọi lại hàm fetch data khi bấm Thử lại
                            context.read<PostBloc>().add(FetchPosts());
                          },
                          child: Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } 
                
                else if (state is PostEmpty) {
                  return Center(child: Text('Không có bài viết nào.'));
                } 
                
                else if (state is PostSuccess) {
                  return RefreshIndicator( // khi kéo xuống sẽ hiện 1 cái bòng tròn xoay
                    onRefresh: () async {
                      context.read<PostBloc>().add(FetchPosts()); // gọi lại event để load lại ds
                    },
                    child: ListView.builder(
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return Card(
                          child: ListTile(
                            title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        );
                      },
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}