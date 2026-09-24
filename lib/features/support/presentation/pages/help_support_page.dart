import 'package:bai_01/features/support/presentation/bloc/support_state.dart';
import 'package:bai_01/features/support/presentation/bloc/support_bloc.dart';
import 'package:bai_01/features/support/presentation/bloc/support_event.dart';
import 'package:bai_01/features/support/presentation/pages/ticket_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HelpSupportPage extends StatefulWidget {
  final int customerId;
  
  const HelpSupportPage({
    super.key,
    required this.customerId,
  });

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(LoadTicketsEvent(widget.customerId));
  }

  @override
  Widget build(BuildContext context) {
    final dynamicCardColor = Theme.of(context).cardColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // kênh liên hệ
            const Text('Liên hệ với chúng tôi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildContactCard(Icons.support_agent, 'Tổng đài CSKH', '1900 1000', Colors.blue),
            _buildContactCard(Icons.email_outlined, 'Email hỗ trợ', 'support@gmail.com', Colors.green), 
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // FAQ
            const Text('Câu hỏi thường gặp (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: dynamicCardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildFaqItem('Làm sao để đổi mật khẩu?', 'Bạn có thể vào mục "Cá nhân" > "Đổi mật khẩu", nhập mật khẩu cũ và mật khẩu mới để cập nhật.'),
                  _buildFaqItem('Tôi quên mật khẩu thì làm thế nào?', 'Tại màn hình Đăng nhập, hãy bấm vào nút "Quên mật khẩu" và làm theo hướng dẫn để khôi phục qua Email.'),
                  _buildFaqItem('Dữ liệu của tôi có được bảo mật không?', 'Tuyệt đối an toàn. Chúng tôi áp dụng các tiêu chuẩn mã hóa dữ liệu tiên tiến nhất hiện nay.'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // lịch sử hỗ trợ
            const Text('Lịch sử yêu cầu hỗ trợ (Tickets)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            BlocBuilder<SupportBloc, SupportState>(
              builder: (context, state) {
                if (state is SupportLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  );
                } 
                
                if (state is SupportError) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)),
                  );
                } 
                
                if (state is SupportLoaded) {
                  final tickets = state.tickets;
                  
                  if (tickets.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Khách hàng này chưa có yêu cầu hỗ trợ nào.', style: TextStyle(fontStyle: FontStyle.italic)),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(alpha: 0.1),
                            child: const Icon(Icons.forum, color: Colors.orange, size: 20),
                          ),
                          title: Text(
                            ticket.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            ticket.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              // nút sửa
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                onPressed: () {
                                  final supportBloc = context.read<SupportBloc>();
                                  _showEditTicketDialog(context, ticket, supportBloc);
                                },
                              ),
                              // nút xóa
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  context.read<SupportBloc>().add(DeleteTicketEvent(ticket.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã xóa vé hỗ trợ #${ticket.id}')),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailPage(ticket: ticket),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 40), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final supportBloc = context.read<SupportBloc>();
          _showCreateTicketDialog(context, widget.customerId, supportBloc);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color iconColor) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.1), child: Icon(icon, color: iconColor)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle), 
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(answer, style: const TextStyle(height: 1.5)), 
        )
      ],
    );
  }

  void _showCreateTicketDialog(BuildContext context, int userId, SupportBloc bloc) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Gửi yêu cầu hỗ trợ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề vấn đề', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();
                
                if (title.isNotEmpty && body.isNotEmpty) {
                  bloc.add(AddTicketEvent(userId: userId, title: title, body: body));
                  Navigator.pop(dialogContext); // Đóng popup
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang gửi yêu cầu...'), backgroundColor: Colors.orange),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Gửi yêu cầu'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTicketDialog(BuildContext context, dynamic ticket, SupportBloc supportBloc) {
    final titleController = TextEditingController(text: ticket.title);
    final bodyController = TextEditingController(text: ticket.body);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sửa yêu cầu hỗ trợ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Nội dung', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                supportBloc.add(
                  UpdateTicketEvent(
                    ticketId: ticket.id,
                    newTitle: titleController.text,
                    newBody: bodyController.text,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        );
      },
    );
  }
}