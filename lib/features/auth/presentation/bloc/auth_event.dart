abstract class AuthEvent {}

// skien đăng nhập
class AuthLoginSubmitted extends AuthEvent {
  final String username;
  final String password;

  AuthLoginSubmitted({required this.username, required this.password});
}
//sk đăng ký
class AuthRegisterSubmitted extends AuthEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;

  AuthRegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
  });

}

// s.kiện quên m.khẩu
class AuthForgotPasswordSubmitted extends AuthEvent {
  final String email;
  AuthForgotPasswordSubmitted(this.email);
}

// s.kiện gửi mã otp xác thực
class AuthOtpSubmitted extends AuthEvent {
  final String otp;
  AuthOtpSubmitted(this.otp);
}

//sk gửi y/c đổi m.khẩu mới
class AuthResetPasswordSubmitted extends AuthEvent {
  final String newPassword;
  AuthResetPasswordSubmitted(this.newPassword);
}