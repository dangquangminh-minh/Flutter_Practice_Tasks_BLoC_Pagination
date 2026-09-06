import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bai_01/features/app/presentation/app_router.dart';

import '../bloc/auth_bloc.dart'; 
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController(); // lấy dl từ ô nhập liệu
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // blocconsumer: vừa nghe state vừa render lại ui
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) { // nghe các staet
          if (state is AuthSuccess) {
            context.go(AppRouter.product);  // đăng nhập ok thì chuyển qua trag sp 
          }
          else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) { //render lai ui khi state đổi
          return SafeArea( 
            child: Center(
              child: SingleChildScrollView( 
                padding: const EdgeInsets.all(24.0), 
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header
                      const SizedBox(height: 24), 
                      const Icon(Icons.lock_person_outlined, size: 64, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Xin chào,\nĐăng nhập ngay!',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vui lòng nhập thông tin để tiếp tục',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // username
                      TextField(
                        controller: _usernameController,
                        autofillHints: const [AutofillHints.username], // gợi ý điền username ̣(máy ảo nên k hiện) 
                        textInputAction: TextInputAction.next, // bấm enter để nahyr uống password
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập (Username)',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0), 
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, 
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done, 
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0), 
                          ),
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
                      ),
                      
                      // Căn phải cho nút Quên mật khẩu
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Chuyển hướng sang trang Quên mật khẩu
                              context.push(AppRouter.forgotPassword);
                            },
                            child: Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // Dùng màu chủ đạo của hệ thống
                                color: Theme.of(context).colorScheme.primary, 
                              ),
                            ),
                          ),
                        ),
                      
                      // nút đang nhập
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // hiệu ứng mờ sau khi bấm đ.nhập
                            disabledBackgroundColor: Colors.blueAccent.withValues(alpha: 0.6),
                          ),
                          // vô hiệu hóa nút tránh spam
                          onPressed: state is AuthLoading ? null : () {
                            final user = _usernameController.text.trim();
                            final pass = _passwordController.text.trim();
                            
                            if (user.isEmpty || pass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập đầy đủ tài khoản và mật khẩu'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            context.read<AuthBloc>().add(
                              AuthLoginSubmitted(username: user, password: pass)
                            );
                          },
                          child: state is AuthLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Đăng nhập', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                        
                      const SizedBox(height: 16),

                      // nút đ.kí
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.push(AppRouter.register); 
                          },
                          child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}