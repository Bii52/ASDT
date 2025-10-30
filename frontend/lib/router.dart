import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';

import 'features/auth/profile_screen.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/articles/articles_page.dart';
import 'features/articles/article_detail_page.dart';
import 'features/reminders/reminders_page.dart';
import 'features/reminders/add_multiple_reminders_page.dart';
import 'features/reminders/add_reminder_page.dart';
import 'features/profile/edit_profile_page.dart';
import 'features/profile/settings_page.dart';
import 'features/profile/change_password_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/welcome/welcome_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/otp_verification_page.dart';
import 'features/auth/reset_password_page.dart';
import 'features/drugs/drug_search_page.dart';
import 'features/drugs/drug_detail_page.dart';
import 'features/drugs/drug_qr_scanner_page.dart';
import 'features/categories/categories_page.dart';
import 'features/chat/pages/conversations_list_page.dart';
import 'features/appointments/doctor_list_page.dart';
import 'features/chat/pages/online_doctors_page.dart';
import 'features/appointments/appointment_list_page.dart';
import 'features/appointments/create_appointment_page.dart';
import 'features/doctor_dashboard/pages/doctor_dashboard_page.dart';

// Pharmacist pages
import 'features/pharmacist/pharmacist_dashboard_page.dart';
import 'features/pharmacist/product_management_page.dart';
import 'features/pharmacist/category_management_page.dart';
import 'features/pharmacist/qr_scanner_page.dart';

// Admin pages (placeholder for now)
import 'features/admin/admin_dashboard_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/welcome',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/welcome'),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpVerificationPage()),
      GoRoute(
          path: '/reset-password',
          builder: (_, __) => const ResetPasswordPage()),

      // User routes
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/articles', builder: (_, __) => const ArticlesPage()),
      GoRoute(
          path: '/articles/:id',
          builder: (ctx, s) => ArticleDetailPage(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/reminders/add',
          builder: (context, state) =>
              AddReminderPage(initialMedicineName: state.extra as String?)),
      GoRoute(path: '/reminders', builder: (_, __) => const RemindersPage()),
      GoRoute(
        path: '/reminders/add-multiple',
        builder: (context, state) => AddMultipleRemindersPage(
          initialMedicineNames: state.extra as List<String>?,
        ),
      ),

      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(
          path: '/settings/change-password',
          builder: (_, __) => const ChangePasswordPage()),
      GoRoute(path: '/drugs', builder: (_, __) => const DrugSearchPage()),
      GoRoute(
          path: '/drugs/scan', builder: (_, __) => const DrugQRScannerPage()),
      GoRoute(
          path: '/drugs/:id',
          builder: (ctx, s) => DrugDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/doctors', builder: (_, __) => const DoctorListPage()),
      GoRoute(path: '/chat', builder: (_, __) => const ConversationsListPage()),
      GoRoute(
          path: '/chat/doctors', builder: (_, __) => const OnlineDoctorsPage()),
      GoRoute(
          path: '/appointments',
          builder: (_, __) => const AppointmentListPage()),
      GoRoute(
          path: '/create-appointment',
          builder: (context, state) =>
              CreateAppointmentPage(doctorId: state.extra as String?)),
      GoRoute(
          path: '/chat/:conversationId',
          builder: (ctx, s) {
            return const ConversationsListPage(); 
          }),

      // Doctor routes
      GoRoute(
          path: '/doctor/dashboard',
          builder: (_, __) => const DoctorDashboardPage()),

      // Pharmacist routes
      GoRoute(
          path: '/pharmacist/dashboard',
          builder: (_, __) => const PharmacistDashboardPage()),
      GoRoute(
          path: '/pharmacist/products',
          builder: (_, __) => const ProductManagementPage()),
      GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage()),
      GoRoute(
          path: '/pharmacist/categories',
          builder: (_, __) => const CategoryManagementPage()),
      GoRoute(
          path: '/pharmacist/qr-scanner',
          builder: (_, __) => const QRScannerPage()),

      // Admin routes
      GoRoute(
          path: '/admin/dashboard',
          builder: (_, __) => const AdminDashboardPage()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.isAuthenticated;
      final userRole = authState.user?.role;
      final location = state.matchedLocation;

      final publicRoutes = [
        '/welcome',
        '/login',
        '/register',
        '/forgot-password',
        '/otp',
        '/reset-password'
      ];

      if (!isAuthenticated) {
   
        return publicRoutes.contains(location) ? null : '/login';
      }


      if (publicRoutes.contains(location)) {

        if (userRole == 'doctor') {
          return '/doctor/dashboard';
        } else if (userRole == 'pharmacist') {
          return '/pharmacist/dashboard';
        } else if (userRole == 'admin') {
          return '/admin/dashboard';
        }
        return '/dashboard'; 
      }


      if (userRole == 'user') {
 
        final userRoutes = [
          '/dashboard',
          '/articles',
          '/reminders',
          '/profile',
          '/drugs',
          '/categories',
          '/chat',
          '/appointments',
          '/create-appointment' // Cho phép user truy cập trang tạo lịch hẹn
        ];
        if (!userRoutes.any((route) => location.startsWith(route))) {
          return '/dashboard';
        }
      } else if (userRole == 'doctor') {
        final doctorRoutes = [
          '/doctor',
          '/profile',
          '/settings',
          '/chat',
          '/appointments',
          '/articles', 
        ];
        if (!doctorRoutes.any((route) => location.startsWith(route))) {
          return '/doctor/dashboard';
        }
      } else if (userRole == 'pharmacist') {
        final pharmacistRoutes = [
          '/pharmacist',
          '/profile',
          '/settings',
          '/categories',
        ];
        if (!pharmacistRoutes.any((route) => location.startsWith(route))) {
          return '/pharmacist/dashboard';
        }
      } else if (userRole == 'admin') {
        final adminRoutes = [
          '/admin',
          '/profile',
          '/settings',
          '/users',
          '/doctors',
          '/products',
          '/categories',
          '/articles',
        ];
        if (!adminRoutes.any((route) => location.startsWith(route))) {
          return '/admin/dashboard';
        }
      }
      return null;
    },
  );
});
