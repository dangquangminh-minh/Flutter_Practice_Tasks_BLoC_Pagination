abstract class ProfileEvent {}

// Sự kiện khi vào trang cá nhân để lấy data
class ProfileFetchStarted extends ProfileEvent {}

// Sự kiện khi bấm nút đăng xuất
class ProfileLogoutRequested extends ProfileEvent {}