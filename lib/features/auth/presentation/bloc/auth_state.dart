abstract class AuthState {}

class AuthInitial extends AuthState {} 
class AuthLoading extends AuthState {} 
class AuthSuccess extends AuthState {} 
class AuthFailure extends AuthState {  
  final String message;
  AuthFailure(this.message);
}

class AuthRegisterSuccess extends AuthState {}

class AuthForgotPasswordSuccess extends AuthState {
  final String email;
  AuthForgotPasswordSuccess(this.email);
}

// xác thực t.công
class AuthOtpSuccess extends AuthState {}

//đổi mật khẩu thành công
class AuthResetPasswordSuccess extends AuthState {}