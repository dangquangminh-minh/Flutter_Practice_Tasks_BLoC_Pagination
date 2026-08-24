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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      
      // blocconsumer tương tự như bên login
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
                backgroundColor: Colors.green,
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
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(labelText: 'Họ'),
                      validator: (value) => value!.isEmpty ? 'Không được để trống' : null, // validate không để trống
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Tên'),
                      validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Tên đăng nhập (Username)'),
                      validator: (value) => value!.length < 3 ? 'Phải dài hơn 3 ký tự' : null,// validate độ dài tôi thiểu
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value!.isEmpty) return 'Không được để trống';
                        if (!value.contains('@')) return 'Email không hợp lệ'; // ktra format
                        return null; 
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Mật khẩu'),
                      obscureText: true, // ẩn 
                      validator: (value) => value!.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
                    ),
                    const SizedBox(height: 32),
                    
                    // nút đăng ký
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
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
                            ? const CircularProgressIndicator()
                            : const Text('ĐĂNG KÝ'),
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