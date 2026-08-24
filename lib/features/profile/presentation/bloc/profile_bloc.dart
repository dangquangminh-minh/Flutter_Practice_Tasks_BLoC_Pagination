import 'package:flutter_bloc/flutter_bloc.dart';
import "package:bai_01/features/auth/data/data_sources/auth_data_source.dart";
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService authService; 

  ProfileBloc(this.authService) : super(ProfileInitial()) {
    on<ProfileFetchStarted>(_onProfileFetchStarted);
    on<ProfileLogoutRequested>(_onProfileLogoutRequested);
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
}
