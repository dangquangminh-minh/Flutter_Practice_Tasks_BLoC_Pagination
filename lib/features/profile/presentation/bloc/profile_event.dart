abstract class ProfileEvent {}

// sk dô trag để lấy data
class ProfileFetchStarted extends ProfileEvent {}

// sk bấm nút đăng xuất
class ProfileLogoutRequested extends ProfileEvent {}