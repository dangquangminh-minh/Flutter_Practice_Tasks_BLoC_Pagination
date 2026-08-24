import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


import 'package:bai_01/features/auth/data/data_sources/auth_data_source.dart'; // Nơi chứa AuthService
import 'package:bai_01/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bai_01/features/auth/presentation/bloc/auth_event.dart';
import 'package:bai_01/features/auth/presentation/bloc/auth_state.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthBloc - Login Test', () {
    blocTest<AuthBloc, AuthState>(
      'Đăng nhập thành công - chuyển sang trạng thái AuthSuccess',
      build: () {
        // Giả lập AuthService trả về true
        when(() => mockAuthService.loginAPI('emilys', 'emilyspass'))
            .thenAnswer((_) async => true);
        return AuthBloc(mockAuthService); 
      },
      // Gọi đúng event AuthLoginSubmitted của bạn
      act: (bloc) => bloc.add(AuthLoginSubmitted(username: 'emilys', password: 'emilyspass')),
      expect: () => [
        isA<AuthLoading>(), // Chờ xử lý
        isA<AuthSuccess>(), // Thành công
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Đăng nhập thất bại - chuyển sang trạng thái AuthFailure',
      build: () {
        // Giả lập AuthService trả về false do sai pass
        when(() => mockAuthService.loginAPI('emilys', 'wrongpass'))
            .thenAnswer((_) async => false);
        return AuthBloc(mockAuthService);
      },
      act: (bloc) => bloc.add(AuthLoginSubmitted(username: 'emilys', password: 'wrongpass')),
      expect: () => [
        isA<AuthLoading>(), // Chờ xử lý
        isA<AuthFailure>(), // Thất bại (báo lỗi)
      ],
    );
  });
}