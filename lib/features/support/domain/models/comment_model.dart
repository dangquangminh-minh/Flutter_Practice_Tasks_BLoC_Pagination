class CommentModel {
  final int id;
  final String body;
  final int postId;
  final String username; 

  CommentModel({
    required this.id,
    required this.body,
    required this.postId,
    required this.username,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      postId: json['postId'] ?? 0,
      username: json['user']?['username'] ?? 'Người dùng ẩn danh',
    );
  }
}