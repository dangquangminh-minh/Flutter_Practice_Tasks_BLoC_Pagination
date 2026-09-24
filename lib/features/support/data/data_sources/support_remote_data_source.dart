import 'package:dio/dio.dart';
import '../../domain/models/support_ticket_model.dart'; 

class SupportRemoteDataSource {

  final Dio dio = Dio(); 

  Future<List<SupportTicket>> getTicketsByUserId(int userId) async {
    try {
      // id khách hàng
      final response = await dio.get('https://dummyjson.com/posts/user/$userId');
      
      if (response.statusCode == 200) {
        final List data = response.data['posts'];
        return data.map((json) => SupportTicket.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } on DioException catch (e) {
      
      // nếu k có dl ̣(404), thì k có ticket trả về amngx rỗng
      if (e.response?.statusCode == 404) {
        return []; 
      }
      throw Exception('Không thể lấy danh sách. Chi tiết: ${e.message}');
    }
  }

  // thêm ticket mới
  Future<SupportTicket> addTicket(String title, String body, int userId) async {
    final response = await dio.post(
      'https://dummyjson.com/posts/add',
      data: {
        'title': title,
        'body': body,
        'userId': userId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SupportTicket.fromJson(response.data);
    }
    throw Exception('Không thể tạo ticket mới');
  }


  // update ticket
  Future<SupportTicket> updateTicket(int ticketId, String newTitle, String newBody) async {
    try {
      final response = await dio.put(
        'https://dummyjson.com/posts/$ticketId',
        data: {
          'title': newTitle,
          'body': newBody,
        },
      );
      if (response.statusCode == 200) {
        return SupportTicket.fromJson(response.data);
      }
      throw Exception('Lỗi server khi cập nhật ticket');
    } catch (e) {
      throw Exception('Không thể cập nhật ticket. Chi tiết: $e');
    }
  }

  // xóa Ticket
  Future<void> deleteTicket(int ticketId) async {
    try {
      final response = await dio.delete('https://dummyjson.com/posts/$ticketId');
      if (response.statusCode != 200) {
        throw Exception('Lỗi server khi xóa ticket');
      }
    } catch (e) {
      throw Exception('Không thể xóa ticket. Chi tiết: $e');
    }
  }

  // lấy ds comment
  Future<List<dynamic>> getCommentsByPostId(int ticketId) async {
    final response = await dio.get('https://dummyjson.com/comments/post/$ticketId');
    
    if (response.statusCode == 200) {
      return response.data['comments'] ?? []; 
    }
    throw Exception('Lỗi tải danh sách comment');
  }

  // thêm comment mới
  Future<dynamic> addComment(String body, int ticketId, int userId) async {
    final response = await dio.post(
      'https://dummyjson.com/comments/add',
      data: {
        'body': body,
        'postId': ticketId,
        'userId': userId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data; 
    }
    throw Exception('Lỗi thêm comment mới');
  }

  // update comment
  Future<dynamic> updateComment(int commentId, String newBody) async {
    try {
      final response = await dio.put(
        'https://dummyjson.com/comments/$commentId',
        data: {'body': newBody},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Lỗi server khi sửa comment');
    } catch (e) {
      throw Exception('Không thể sửa comment. Chi tiết: $e');
    }
  }

  // xóa cmt
  Future<dynamic> deleteComment(int commentId) async {
    try {
      final response = await dio.delete('https://dummyjson.com/comments/$commentId');
      if (response.statusCode == 200) {
        return response.data; 
      }
      throw Exception('Lỗi server khi xóa comment');
    } catch (e) {
      throw Exception('Không thể xóa comment. Chi tiết: $e');
    }
  }

}