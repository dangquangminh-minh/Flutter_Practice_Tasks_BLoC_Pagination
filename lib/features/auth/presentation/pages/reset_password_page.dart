import 'package:bai_01/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bai_01/features/auth/presentation/bloc/auth_event.dart';
import 'package:bai_01/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo mật khẩu mới'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(24.0),
        

        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // t.công thì bật dialog
            if (state is AuthResetPasswordSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Đổi mật khẩu thành công', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  content: const Text(
                    'Mật khẩu của bạn đã được cập nhật. Vui lòng đăng nhập lại để tiếp tục.',
                    style: TextStyle(height: 1.5),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.go('/login'); //đưa ra trang login
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              );
            } 
            //lỗi thì show snackbar
            else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            // hiện laoding để vô hiệu háo nút
            final isLoading = state is AuthLoading;

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _passController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới', 
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (val.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu', 
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (val) => val != _passController.text ? 'Mật khẩu không khớp' : null,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: isLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState!.validate()) {
                                
                                context.read<AuthBloc>().add(
                                  AuthResetPasswordSubmitted(_passController.text),
                                );
                              }
                            },
                      child: isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('Xác nhận thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}