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
  final TextEditingController _usernameController = TextEditingController(); // lấy dl từ ô nhập liệu
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập API DummyJSON')),
      
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // ẩn mật khẩu *****
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                
                // trạng thái loading
                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      final user = _usernameController.text.trim();
                      final pass = _passwordController.text.trim();
                      
                      // nhả event cho bloc xly
                      context.read<AuthBloc>().add(
                        AuthLoginSubmitted(username: user, password: pass)
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
                  
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.push(AppRouter.register); // chuyển qua mh đky
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}