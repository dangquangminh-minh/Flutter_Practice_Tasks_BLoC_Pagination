import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bai_01/features/app/presentation/app_router.dart';


import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

@override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  // hàm để gọi api khi mở tab lên
  @override
  void initState() {
    super.initState();
    // bắn event lấy thông tin cá nhân
    context.read<ProfileBloc>().add(ProfileFetchStarted()); 
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          //xem trạng thái đăng xuất t.công để đưa ra login
          if (state is ProfileLogoutSuccess) {
            context.go(AppRouter.login);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) { // gọi api lấy thông tin và hiện vòng xoay
            return const Center(child: CircularProgressIndicator());
          } 
          
          // else if (state is ProfileError) {
          //   return Center(child: Text(state.message));
          // } 
          
          //lấy data thành công  hiển thị avatar và tt
          else if (state is ProfileLoaded) {
            final user = state.userData;
            return SingleChildScrollView( // bọc vô đây để chống tràn màn hình sọc vàng đen
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: NetworkImage(user['image']),//load ảnh từ url mà api trả về 
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${user['firstName']} ${user['lastName']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user['email'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Role: ${user['role'] ?? 'Chưa xác định'}', // TH: api trả về null thì tự động "cxđ"
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500, 
                        color: Colors.blueAccent
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
     
                  _buildMenuRow(Icons.person_outline, 'Chỉnh sửa hồ sơ', () {
                    context.push(AppRouter.editProfile);
                  }),
                  _buildMenuRow(Icons.lock_outline, 'Đổi mật khẩu', () {
                    context.push(AppRouter.changePassword);
                  }),
                  _buildMenuRow(Icons.settings_outlined, 'Cài đặt hệ thống', () {
                    context.push(AppRouter.settings); // Mở trang Settings lên
                  }),
                  _buildMenuRow(Icons.help_outline, 'Trợ giúp & Hỗ trợ', () {
                    context.push(AppRouter.helpSupport); 
                  }),

                  const SizedBox(height: 16),
                  const Divider(), //đường kẻ
                  const SizedBox(height: 8),

                  // nút đăng xuất
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.logout, color: Colors.redAccent),
                    ),
                    title: const Text(
                      'Đăng xuất', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                    ),
                    onTap: () {
                      context.read<ProfileBloc>().add(ProfileLogoutRequested());
                    },
                  ),

                  const SizedBox(height: 32),
                  
                  //nút refresh session                
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(ProfileRefreshSessionRequested());
                      },
                      child: const Text(
                        'Refresh Session', 
                        style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // // nút đăng xuất bắn event lên bloc
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.red.shade400,
                  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //     ),
                  //     onPressed: () {
                  //       context.read<ProfileBloc>().add(ProfileLogoutRequested());
                  //     },
                  //     child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 16)),
                  //   ),
                  // ),
                ],
              ),
            );
          }

          return const Center(child: Text('Đang khởi tạo...'));
        },
      ),
    );
  }

  // hàm vẽ các menuu
  Widget _buildMenuRow(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),     
        onTap: onTap,
      ),
    );
  }
}