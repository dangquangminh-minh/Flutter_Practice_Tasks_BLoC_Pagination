abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {// trạng thái tải dữ liệu th.công
  final Map<String, dynamic> userData;
  ProfileLoaded(this.userData);
}
class ProfileError extends ProfileState {// tải dl thất bạii
  final String message;
  ProfileError(this.message);
}
class ProfileLogoutSuccess extends ProfileState {}// đăng xuất t.công