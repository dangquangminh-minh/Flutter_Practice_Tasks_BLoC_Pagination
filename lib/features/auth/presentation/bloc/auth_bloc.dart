import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/auth_data_source.dart'; 
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService; // nhận từ bên ngoài , không gọi trực tiếp 

  AuthBloc(this.authService) : super(AuthInitial()) {
    // sk đăng nhập
    on<AuthLoginSubmitted>(_onLoginSubmitted);

    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
  }

  // hàm xử lý các sk của đăng nhập
  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
      // validate
    if (event.username.isEmpty || event.password.isEmpty) {
      emit(AuthFailure('Vui lòng nhập đầy đủ Username và Password!'));
      return;
    }

    // hiện Loading
    emit(AuthLoading());

    // gọi api đnhap thông qua authservice
    final isSuccess = await authService.loginAPI(event.username, event.password);

    // trả về kết quả
    if (isSuccess) {
      emit(AuthSuccess());// chuyển về trang sp
    } else {
      emit(AuthFailure('Sai Username hoặc Password. Vui lòng thử lại!'));
    }
  }

// xử lý sk đăng ký
  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // hiện Loading
    emit(AuthLoading());

    // gọi api đky
    final isSuccess = await authService.registerAPI(
      firstName: event.firstName,
      lastName: event.lastName,
      username: event.username,
      email: event.email,
      password: event.password,
    );

    // phản hồi kết quả
    if (isSuccess) {
      emit(AuthRegisterSuccess()); // ok thì quay lại trag login
    } else {
      emit(AuthFailure('Đăng ký thất bại! Vui lòng thử lại.'));
    }
  }
}