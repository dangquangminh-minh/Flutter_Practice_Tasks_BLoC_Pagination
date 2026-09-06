import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/auth_data_source.dart'; 
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService; // nhận từ bên ngoài , không gọi trực tiếp (authservice là auth/data/data_source/auth_data_source.dart(bài 6 cũ))

  AuthBloc(this.authService) : super(AuthInitial()) {
    // sk đăng nhập
    on<AuthLoginSubmitted>(_onLoginSubmitted);

    on<AuthRegisterSubmitted>(_onRegisterSubmitted);

    on<AuthForgotPasswordSubmitted>(_onForgotPasswordSubmitted);

    on<AuthResetPasswordSubmitted>(_onResetPasswordSubmitted);

    on<AuthOtpSubmitted>(_onOtpSubmitted);
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

  //hàm x.lý quên m.khẩu
  Future<void> _onForgotPasswordSubmitted(
    AuthForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isEmailValid = await authService.checkEmailExists(event.email);

      if (isEmailValid) {
        // thấy email thì phát ra state t.công
        emit(AuthForgotPasswordSuccess(event.email));
      } else {
        emit(AuthFailure('Email không tồn tại trong hệ thống!'));
      }
    } catch (e) {
      emit(AuthFailure('Lỗi kết nối máy chủ. Vui lòng thử lại sau!'));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    AuthResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // hiện v.xoay
    emit(AuthLoading());

    // giả lập time update api
    await Future.delayed(const Duration(milliseconds: 1500));

    // dumsjon k hỗ trợ nên ném ra t.công luôn
    emit(AuthResetPasswordSuccess());
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {

    emit(AuthLoading());

    // giả lập
    await Future.delayed(const Duration(seconds: 1));
    //fake api trả về otp
    if (event.otp == '123456') {
      emit(AuthOtpSuccess());
    } else {
      emit(AuthFailure('Mã OTP không chính xác!'));
    }
  }
}