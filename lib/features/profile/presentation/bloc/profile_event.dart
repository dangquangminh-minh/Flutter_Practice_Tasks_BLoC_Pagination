abstract class ProfileEvent {}

// sk dô trag để lấy data
class ProfileFetchStarted extends ProfileEvent {}

// sk bấm nút đăng xuất
class ProfileLogoutRequested extends ProfileEvent {}


class ProfileRefreshSessionRequested extends ProfileEvent {}

// update t.tin cá nhân
class ProfileUpdateRequested extends ProfileEvent {
  final String fullName;
  final String email;
  final String phone;

  ProfileUpdateRequested({
    required this.fullName,
    required this.email,
    required this.phone,
  });
}

// sk đổi mật khẩu trong profile
class ProfilePasswordChangeRequested extends ProfileEvent {
  final String newPassword;
  final String oldPassword;

  ProfilePasswordChangeRequested({required this.newPassword,required this.oldPassword,});
}