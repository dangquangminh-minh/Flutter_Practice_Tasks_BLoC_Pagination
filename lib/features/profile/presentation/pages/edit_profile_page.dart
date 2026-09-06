import 'package:bai_01/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bai_01/features/profile/presentation/bloc/profile_event.dart';
import 'package:bai_01/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key}); 

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Khởi tạo rỗng, không chứa logic parse data ở đây nữa
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // GIAO DIỆN SIÊU SẠCH: Bóc dữ liệu đưa vào form mà không cần ghép chuỗi lằng nhằng
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _initFormData(profileState.userData);
    }
  }


  void _initFormData(Map<String, dynamic> userData) {
    _nameController.text = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
    _emailController.text = userData['email'] ?? '';
    _phoneController.text = userData['phone'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), backgroundColor: Colors.green),
            );
            if (Navigator.canPop(context)) Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          
          String avatarUrl = 'https://dummyjson.com/icon/emilys/128'; 
          if (state is ProfileLoaded && state.userData['image'] != null) {
            avatarUrl = state.userData['image'];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(avatarUrl),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tính năng đổi ảnh đang phát triển')),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.black87,
                              radius: 16,
                              child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField('Họ và tên', _nameController, Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField('Email', _emailController, Icons.email_outlined, isEmail: true),
                  const SizedBox(height: 16),
                  _buildTextField('Số điện thoại', _phoneController, Icons.phone_outlined, isPhone: true),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          //bắn event
                          context.read<ProfileBloc>().add(
                            ProfileUpdateRequested(
                              fullName: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                            ),
                          );
                        }
                      },
                      child: isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black87)),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }
}