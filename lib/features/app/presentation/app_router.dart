import 'package:bai_01/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bai_01/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:bai_01/features/auth/presentation/pages/reset_password_page.dart' show ResetPasswordPage;
import 'package:bai_01/features/profile/presentation/pages/help_support_page.dart';
import 'package:bai_01/features/profile/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';
import 'package:bai_01/features/app/presentation/pages/dashboard_page.dart';
import 'package:bai_01/features/products/presentation/pages/cache_retry_page.dart';
import 'package:bai_01/features/customers/presentation/pages/customer_page.dart';
import 'package:bai_01/features/profile/presentation/pages/profile_page.dart';
import "package:bai_01/features/auth/presentation/pages/login_page.dart";
import 'package:bai_01/features/auth/presentation/pages/splash_page.dart';
import 'package:bai_01/features/auth/presentation/pages/register_page.dart';
import 'package:bai_01/features/customers/presentation/pages/customer_detail_page.dart';
import 'package:bai_01/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:bai_01/features/profile/presentation/pages/change_password_page.dart';

class AppRouter {
  static const String product = '/product'; //cache_retry // tránh gõ sai đg link chỉ gần gọi approuter.product
  static const String customer = '/customer';
  static const String profile = '/profile';
  static const String splash = '/splash';
  static const String login = '/login'; 
  static const String register = '/register';
  static const String customerDetail = '/customer-detail/:id';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  
  static final GoRouter router = GoRouter(
    initialLocation: splash, // mới chạy app là bay dô splash
    routes: [

      // otp
      GoRoute(
        path: otp,
        builder: (context, state) {
          final email = state.extra as String? ?? 'Email của bạn'; //nhận email từ trg quên m.khẩu
          return OtpVerificationPage(email: email);
        },
      ),

      //reset pass khi quên mật khẩu
      GoRoute(
        path: resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),

      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: helpSupport,
        builder: (context, state) => const HelpSupportPage(),
      ),
      
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(), 
      ),

      // đổi mật khẩu trong profile
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),

      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
     

    // toàn màn hình nên bỏ ra StatefulShellRoute.indexedStack(
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(), // đăng nhập
      ),

      
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(), // m hình chờ trong lúc khởi động
      ),

      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),// đký
      ), 


      GoRoute(
        path: AppRouter.customerDetail, // tương đương '/customer-detail/:id'
        builder: (context, state) {
          // lấy id
          final idString = state.pathParameters['id'];
          
          // ép kiểu parse thành int
          final id = int.parse(idString!);
          
          // trả về ui kèm id
          return CustomerDetailPage(customerId: id);
        },
      ),


            // khung bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardPage(navigationShell: navigationShell); 
        },
        branches: [
          StatefulShellBranch( // dùng nó để k bị reload khi chuyển tab
            routes: [
              GoRoute(
                path: product,
                builder: (context, state) => const Bai6(), // trỏ về trang bài 6 ̣(trang hiện sp)
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: customer,
                builder: (context, state) => const CustomerFeatureEntry(), // trỏ về khách hàng
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfilePage(), // trỏ về trg cá nhân
              ),
            ],
          ),
        ],
      ),
    ],
  );
}