import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../bloc/auth_bloc.dart'; 
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // key dùng qly state của form

  final _firstNameCtrl = TextEditingController(); // các controller để lấy dl từ ô nhập
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        
        elevation: 0, // Bỏ bóng mờ
        iconTheme: const IconThemeData(),
        title: const Text('Đăng ký tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      // blocconsumer tương tự như bên login
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop(); // lùi về trag login
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,// kích hoạt validate
              child: SingleChildScrollView(
                child: Column(
                  children: [                   
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điền thông tin của bạn bên dưới',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),

                   Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // căn trên để khi báo lỗi không bị lệch form
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Họ',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) => value!.isEmpty ? 'Không bỏ trống' : null, // validate không để trống
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Tên',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) => value!.isEmpty ? 'Không bỏ trống' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                        controller: _usernameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập (Username)',
                          prefixIcon: const Icon(Icons.account_circle_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.length < 3 ? 'Phải dài hơn 3 ký tự' : null, // validate độ dài tôi thiểu
                      ),
                      const SizedBox(height: 16),

                    TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Không được để trống';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');  //r'^[\w-\.]+ : bắt buộc phải ghi tên trước dấu "." ,([\w-]+\.)+: tên của nhà mạng ,[\w-]{2,4} : phần đuôi phải có từ 2-4 ký tự
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Email không hợp lệ '; 
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    
                    TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword, // ẩn 
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value!.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
                      ),
                      const SizedBox(height: 32),

                    // nút đăng ký
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          //khóa không cho bấm để tránh bấm 2l
                          onPressed: state is AuthLoading ? null : () {
                            // vướt qua validate thì mới nhả event ra
                            if (_formKey.currentState!.validate()) {
                              //gọi bloc 
                              context.read<AuthBloc>().add(
                                AuthRegisterSubmitted(
                                  firstName: _firstNameCtrl.text.trim(),
                                  lastName: _lastNameCtrl.text.trim(),
                                  username: _usernameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  password: _passwordCtrl.text.trim(),
                                )
                              );
                            }
                          },
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}