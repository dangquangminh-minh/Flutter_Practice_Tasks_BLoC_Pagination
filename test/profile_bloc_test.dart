import 'package:bai_01/features/auth/data/data_sources/auth_data_source.dart';
import 'package:bai_01/features/profile/data/data_sources/profile_data_source.dart';
import 'package:bai_01/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bai_01/features/profile/presentation/bloc/profile_event.dart';
import 'package:bai_01/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}
class MockProfileService extends Mock implements ProfileService {}

void main() {
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late ProfileBloc profileBloc;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    profileBloc = ProfileBloc(
      mockAuthService, 
      mockProfileService,
    );
  });

  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc - Unit Tests', () {
    
    // test logout
    blocTest<ProfileBloc, ProfileState>(
      'Logout thành công: Xóa token và chuyển state',
      build: () {
        when(() => mockAuthService.logout()).thenAnswer((_) async {});
        return profileBloc;
      },
      act: (bloc) => bloc.add(ProfileLogoutRequested()), 
      expect: () => [
        isA<ProfileLogoutSuccess>(), 
      ],
      verify: (_) {
        verify(() => mockAuthService.logout()).called(1);
      },
    );

    // test refesh token
    blocTest<ProfileBloc, ProfileState>(
      'Refresh Token thành công',
      build: () {
        when(() => mockAuthService.refreshSession()).thenAnswer((_) async => true);
        return profileBloc;
      },
      act: (bloc) => bloc.add(ProfileRefreshSessionRequested()), 
      verify: (_) {
        verify(() => mockAuthService.refreshSession()).called(1);
      },
    );

    // test update profile
    blocTest<ProfileBloc, ProfileState>(
      'Cập nhật Profile thành công: Tách đúng FirstName và LastName',
      build: () {
        profileBloc.emit(ProfileLoaded({'id': 1, 'firstName': 'Cũ', 'lastName': 'Tên'}));
        
        when(() => mockProfileService.updateProfile(
          userId: any(named: 'userId'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
        )).thenAnswer((_) async => {'firstName': 'Minh', 'lastName': 'Đặng Quang'});
        
        return profileBloc;
      },
      act: (bloc) => bloc.add(ProfileUpdateRequested(
        fullName: 'Đặng Quang Minh', 
        email: 'minh@email.com',
        phone: '0123456789',
      )),
      expect: () => [
        isA<ProfileLoaded>(), 
      ],
    );
  });
}