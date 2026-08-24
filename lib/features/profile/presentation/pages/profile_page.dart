import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bai_01/features/app/presentation/app_router.dart';


import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          
          else if (state is ProfileError) {
            return Center(child: Text(state.message));
          } 
          
          //lấy data thành công  hiển thị avatar avf tt
          else if (state is ProfileLoaded) {
            final user = state.userData;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
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
                  const Spacer(),
                  
                  // nút đăng xuất bắn event lên bloc
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        context.read<ProfileBloc>().add(ProfileLogoutRequested());
                      },
                      child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Đang khởi tạo...'));
        },
      ),
    );
  }
}