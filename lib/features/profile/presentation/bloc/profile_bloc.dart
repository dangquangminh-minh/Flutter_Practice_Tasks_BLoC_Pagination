import 'package:bai_01/features/profile/data/data_sources/profile_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:bai_01/features/auth/data/data_sources/auth_data_source.dart";
import 'profile_event.dart';
import 'profile_state.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService authService; 
  final ProfileService profileService;

  ProfileBloc(this.authService,this.profileService) : super(ProfileInitial()) {
    on<ProfileFetchStarted>(_onProfileFetchStarted);
    on<ProfileLogoutRequested>(_onProfileLogoutRequested);
    on<ProfileRefreshSessionRequested>(_onProfileRefreshSessionRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfilePasswordChangeRequested>(_onPasswordChangeRequested);
  }

  // lấy thông tin user
  Future<void> _onProfileFetchStarted(
    ProfileFetchStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final userData = await authService.getProfile();
      if (userData != null) {
        emit(ProfileLoaded(userData));
      } else {
        emit(ProfileError('Không lấy được thông tin. Vui lòng đăng nhập lại.'));
      }
    } catch (e) {
      emit(ProfileError('Lỗi kết nối: $e'));
    }
  }

  // đăng xuất
  Future<void> _onProfileLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await authService.logout();
    emit(ProfileLogoutSuccess());
  }

  // hàm x.lý refresh session
  Future<void> _onProfileRefreshSessionRequested(
    ProfileRefreshSessionRequested event,
    Emitter<ProfileState> emit,
    ) async {
    try {
      await authService.refreshSession();
      // làm mới token ngầm , k nhả state mới 
    } catch (e) {
      emit(ProfileError('Lỗi refresh token: $e'));
    }
  }

 Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    if (currentState is ProfileLoaded) {
      try {
        //lấy id của user hiện tại
        final userId = currentState.userData['id']; 
        
       final updatedDataFromApi = await profileService.updateProfile(
          userId: userId,
          firstName: event.fullName,
          lastName: '', 
          email: event.email,
          phone: event.phone,
        );         
          //giữ t.tin cũ và đè thông tin mới lên
          final mergedData = Map<String, dynamic>.from(currentState.userData)
            ..addAll(updatedDataFromApi);

          //cập nhật lại ui
          emit(ProfileLoaded(mergedData));
          
        } catch (e) {
        emit(ProfileError("Cập nhật thất bại: ${e.toString()}"));
      }
    }
  }

  Future<void> _onPasswordChangeRequested(
    ProfilePasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {

      //ktra m.khẩu cũ
      final realPassword = currentState.userData['password'];
      // ss m.khẩu cũ vs m.khẩu mới
      if (realPassword != null && event.oldPassword != realPassword) {
        emit(ProfileError('Mật khẩu cũ không chính xác!'));
        return; // dừng lại để k chạy api dưới
      }

      try {
        final userId = currentState.userData['id'];
        final isSuccess = await profileService.changePassword(
          userId: userId, 
          newPassword: event.newPassword,
        );

        if (isSuccess) {
          emit(ProfileLogoutSuccess());
        } else {
          emit(ProfileError("Lỗi server. Không thể cập nhật."));
        }
      } catch (e) {
         emit(ProfileError("Đổi mật khẩu thất bại: ${e.toString()}"));
      }
    }
  }
}