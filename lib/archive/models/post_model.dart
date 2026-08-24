//jsonplaceholder
// cho bài 1 2 3
class Post {
  //các thuộc tính để lưu thông tin
  final int id;    
  final int userId;
  final String title;
  final String body;

  Post({
    // constructor
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  // Factory constructor để parse JSON
  // sử dụng dynamic vì value chứa rất nhiều kiểu dữ liệu khác nhau
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}