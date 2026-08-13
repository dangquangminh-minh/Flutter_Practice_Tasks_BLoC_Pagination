import 'package:equatable/equatable.dart';

import '../models/post.dart';
abstract class PostState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {} //trạng thái khởi tạo

class PostLoading extends PostState {}// tr.thái đang chờ xử lý 

class PostSuccess extends PostState { //tr.thái thành công khi đưa danh sách thanh công 
  final List<Post> posts;
  PostSuccess(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostEmpty extends PostState {} // trạng thái load ds thành công nhưng rỗng

class PostFailure extends PostState { // tr.thái load ds thất bại kèm lý do errorMessage
  final String errorMessage;
  PostFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}