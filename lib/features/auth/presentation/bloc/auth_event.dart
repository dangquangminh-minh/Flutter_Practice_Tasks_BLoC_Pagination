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