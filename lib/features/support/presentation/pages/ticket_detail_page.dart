import 'package:bai_01/features/support/presentation/bloc/support_bloc.dart';
import 'package:bai_01/features/support/presentation/bloc/support_event.dart';
import 'package:bai_01/features/support/presentation/bloc/support_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class TicketDetailPage extends StatefulWidget {
  final dynamic ticket; 

  const TicketDetailPage({super.key, required this.ticket});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _statusOptions = ['Open', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    // gọi api lấy ds comment
    context.read<SupportBloc>().add(LoadTicketCommentsEvent(widget.ticket.id));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // hàm hiển thị để sửa bình luận
  void _showEditDialog(BuildContext context, int commentId, String currentBody) {
    final TextEditingController editController = TextEditingController(text: currentBody);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa bình luận'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Nhập nội dung mới...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  // bắn event sửa cmt
                  context.read<SupportBloc>().add(
                    UpdateCommentEvent(
                      ticketId: widget.ticket.id,
                      commentId: commentId,
                      newBody: editController.text.trim(),
                    ),
                  );
                  Navigator.pop(context); 
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${widget.ticket.id}'),
        backgroundColor: Colors.orange,
      ),
      body: BlocBuilder<SupportBloc, SupportState>(
        builder: (context, state) {
          // lấy dl từ sstate , nếu ch laod xong thì dùng mặc định 
          String currentStatus = 'Open';
          List<dynamic> comments = [];

          if (state is SupportLoaded) {
            currentStatus = state.ticketStatuses[widget.ticket.id] ?? 'Open';
            comments = state.commentsMap[widget.ticket.id] ?? [];
          }

          return Column(
            children: [
              // thông tin và t.thái ticket
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.withValues(alpha: 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trạng thái xử lý:', style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: currentStatus,
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: status == 'Resolved' ? Colors.green : (status == 'In Progress' ? Colors.blue : Colors.red),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              // bắn event thay đổi t.thái
                              context.read<SupportBloc>().add(ChangeTicketStatusEvent(widget.ticket.id, newValue));
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã cập nhật trạng thái thành: $newValue')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(widget.ticket.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.ticket.body, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              //ds lịch sử cmt
              Expanded(
                child: Container(
                  color: Colors.grey.withValues(alpha: 0.1),
                  child: state is SupportLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : comments.isEmpty
                      ? const Center(child: Text('Chưa có phản hồi nào.', style: TextStyle(fontStyle: FontStyle.italic)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final commentId = comment['id'];
                            final username = comment['user']?['username'] ?? 'Khách';
                            final body = comment['body'] ?? '';

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(body),
                                ),
                                // nút sửa / xóa
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                      onPressed: () => _showEditDialog(context, commentId, body),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () {
                                        // Bắn Event Xóa
                                        context.read<SupportBloc>().add(DeleteCommentEvent(ticketId: widget.ticket.id, commentId: commentId));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),

              //khung nhập cmt mới
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, -1), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Nhập phản hồi...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () {
                          if (_commentController.text.trim().isNotEmpty) {
                            context.read<SupportBloc>().add(
                              AddCommentEvent(
                                ticketId: widget.ticket.id, 
                                body: _commentController.text.trim(),
                                userId: 1, 
                              )
                            );                      
                            _commentController.clear();

                            FocusScope.of(context).unfocus(); 
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}