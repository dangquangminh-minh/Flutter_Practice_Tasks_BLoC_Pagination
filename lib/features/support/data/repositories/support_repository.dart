import 'dart:convert'; 
import '../../domain/models/support_ticket_model.dart';
import '../data_sources/support_remote_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/ticket_local_model.dart'; 

class SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  final List<SupportTicket> _localTicketsCache = []; 
  final Set<int> _deletedTicketIdsCache = {};


  static final List<TicketLocalModel> _localStatusesCache = [];
  static bool _isCacheLoaded = false;

  SupportRepository({required this.remoteDataSource});

  // kéo dl từ shared lên
  Future<void> _loadFromDisk() async {
    if (_isCacheLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('ticket_statuses_db');
    
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      _localStatusesCache.clear();
      _localStatusesCache.addAll(decoded.map((e) => TicketLocalModel.fromJson(e)));
    }
    _isCacheLoaded = true;
  }

  Future<List<SupportTicket>> getTicketsByUserId(int userId) async {
    try {
      await _loadFromDisk();

      final apiTickets = await remoteDataSource.getTicketsByUserId(userId);

      final localTicketsForThisUser = _localTicketsCache
          .where((ticket) => ticket.userId == userId) 
          .toList();

      final allTickets = [...localTicketsForThisUser, ...apiTickets];

      final finalTickets = allTickets
          .where((ticket) => !_deletedTicketIdsCache.contains(ticket.id))
          .toList();

      return finalTickets;
    } catch (e) {
      throw Exception('Lỗi tải danh sách vé: $e');
    }
  }


  Future<void> saveTicketLocalData(int postId, int customerId, String status) async {
    await _loadFromDisk();

    final index = _localStatusesCache.indexWhere((t) => t.postId == postId);
    
    if (index != -1) {
      _localStatusesCache[index] = TicketLocalModel(
        id: _localStatusesCache[index].id, 
        postId: postId,
        customerId: customerId,
        status: status,
        updatedAt: DateTime.now(), 
      );
    } else {
      _localStatusesCache.add(TicketLocalModel(
        id: DateTime.now().millisecondsSinceEpoch, 
        postId: postId,
        customerId: customerId,
        status: status,
        updatedAt: DateTime.now(),
      ));
    }

    // đóng gói thanh json cất vào máy
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_localStatusesCache.map((e) => e.toJson()).toList());
    await prefs.setString('ticket_statuses_db', encodedData);

    debugPrint('Đã lưu Local Ticket $postId VÀO Ổ CỨNG với trạng thái: $status');
  }

  Map<int, String> getAllSavedStatuses() {
    return { for (var item in _localStatusesCache) item.postId : item.status };
  }


  Future<SupportTicket> addTicket(String title, String body, int userId) async {
    final newTicket = await remoteDataSource.addTicket(title, body, userId);
    _localTicketsCache.insert(0, newTicket);
    return newTicket;
  }

  Future<void> deleteTicket(int ticketId) async {
    _deletedTicketIdsCache.add(ticketId);
    _localTicketsCache.removeWhere((t) => t.id == ticketId);
  }

  Future<List<dynamic>> getCommentsByPostId(int ticketId) async {
    return await remoteDataSource.getCommentsByPostId(ticketId);
  }

  Future<dynamic> addComment(String body, int ticketId, int userId) async {
    return await remoteDataSource.addComment(body, ticketId, userId);
  }

  Future<void> updateComment(int commentId, String newBody) async {
    await remoteDataSource.updateComment(commentId, newBody);
  }

  Future<void> deleteComment(int commentId) async {
    await remoteDataSource.deleteComment(commentId);
  }

  void saveTicketToLocalCache(SupportTicket ticket) {
    _localTicketsCache.insert(0, ticket);
  }
}