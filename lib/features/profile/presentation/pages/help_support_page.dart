import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamicCardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // kênh liên hệ
          const Text('Liên hệ với chúng tôi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildContactCard(Icons.support_agent, 'Tổng đài CSKH', '1900 1000', Colors.blue),
          _buildContactCard(Icons.email_outlined, 'Email hỗ trợ', 'support@gmail.com', Colors.green), 
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // câu hỏi thg gặp
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
        ],
      ),
    );
  }

  // card liên hệ
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
        onTap: () {
        },
      ),
    );
  }

  // bấm dô xổ xuống
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
}