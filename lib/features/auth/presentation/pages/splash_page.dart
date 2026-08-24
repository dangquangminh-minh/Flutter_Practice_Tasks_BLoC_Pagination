
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:bai_01/features/app/presentation/app_router.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bai_01/features/auth/data/data_sources/auth_data_source.dart';

// nhiệm vụ: ktra phiên đăng nhập có token hay k

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
 

  @override
  void initState() {
    super.initState();
    _checkAuth(); //vừa vào là nó ktra khóa 
  }

  Future<void> _checkAuth() async {
    // dừng 1s để hiện laoding
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) { 
      // lấy authservice từ main.dart
      final authService = context.read<AuthService>();
      
      // ktra có khóa ch trong storage qua hastoken
      final isLoggedIn = await authService.hasToken();

      if (!mounted) return; //if trong lúc gọi api mà tắt mh thì phải gọi amounted lại để app k bị crash

      if (isLoggedIn) {
        // Nếu có token thì chuyển sang trang sản phẩm
        context.go(AppRouter.product);
      } else {
        // Không có token thì văng ra lại trang đăng nhập
        context.go(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // hiển thị một vòng xoay loading ở giữa màn hình trong lúc chờ kiểm tra
        child: CircularProgressIndicator(),
      ),
    );
  }
}