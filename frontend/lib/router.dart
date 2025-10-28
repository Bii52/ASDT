import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';

// Import all the page widgets
import 'features/auth/profile_screen.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/articles/articles_page.dart';
import 'features/articles/article_detail_page.dart';
import 'features/reminders/reminders_page.dart';
import 'features/reminders/add_reminder_page.dart';
import 'features/profile/edit_profile_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/welcome/welcome_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/otp_verification_page.dart';
import 'features/auth/reset_password_page.dart';
import 'features/drugs/drug_search_page.dart';
import 'features/drugs/drug_detail_page.dart';
import 'features/categories/categories_page.dart';
import 'features/chat/pages/conversations_list_page.dart';
import 'features/chat/pages/start_chat_page.dart';
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

// Test pages
import 'features/test/role_test_page.dart';

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
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpVerificationPage()),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordPage()),
      
      // User routes
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/articles', builder: (_, __) => const ArticlesPage()),
      GoRoute(path: '/articles/:id', builder: (ctx, s) => ArticleDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/reminders', builder: (_, __) => const RemindersPage()),
      GoRoute(path: '/reminders/add', builder: (_, __) => const AddReminderPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
      GoRoute(path: '/drugs', builder: (_, __) => const DrugSearchPage()),
      GoRoute(path: '/drugs/:id', builder: (ctx, s) => DrugDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage()),
      GoRoute(path: '/chat', builder: (_, __) => const ConversationsListPage()),
      GoRoute(path: '/chat/start', builder: (_, __) => const StartChatPage()),
      GoRoute(path: '/chat/doctors', builder: (_, __) => const OnlineDoctorsPage()),
      GoRoute(path: '/appointments', builder: (_, __) => const AppointmentListPage()),
      GoRoute(path: '/create-appointment', builder: (_, __) => const CreateAppointmentPage()),
      GoRoute(path: '/chat/:conversationId', builder: (ctx, s) {
        // TODO: Load conversation from ID and pass to ChatDetailPage
        return const ConversationsListPage(); // Temporary fallback
      }),

      // Doctor routes
      GoRoute(path: '/doctor/dashboard', builder: (_, __) => const DoctorDashboardPage()),
      
      // Pharmacist routes
      GoRoute(path: '/pharmacist/dashboard', builder: (_, __) => const PharmacistDashboardPage()),
      GoRoute(path: '/pharmacist/products', builder: (_, __) => const ProductManagementPage()),
      GoRoute(path: '/pharmacist/categories', builder: (_, __) => const CategoryManagementPage()),
      GoRoute(path: '/pharmacist/qr-scanner', builder: (_, __) => const QRScannerPage()),
      
      // Admin routes
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardPage()),
      
      // Test routes
      GoRoute(path: '/test-roles', builder: (_, __) => const RoleTestPage()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.isAuthenticated;
      final userRole = authState.user?.role;
      final location = state.matchedLocation;

      final publicRoutes = ['/welcome', '/login', '/register', '/forgot-password', '/otp', '/reset-password'];

      if (!isAuthenticated) {
        // If not authenticated, only allow access to public routes
        return publicRoutes.contains(location) ? null : '/login';
      }

      // If authenticated
      if (publicRoutes.contains(location)) {
        // If on a public route, redirect to the appropriate dashboard
        if (userRole == 'doctor') {
          return '/doctor/dashboard';
        } else if (userRole == 'pharmacist') {
          return '/pharmacist/dashboard';
        } else if (userRole == 'admin') {
          return '/admin/dashboard';
        }
        return '/dashboard'; // Default for user role
      }

      // Role-based access control
      if (userRole == 'user') {
        // User can only access user routes
        final userRoutes = ['/dashboard', '/articles', '/reminders', '/profile', '/drugs', '/categories', '/chat', '/appointments'];
        if (!userRoutes.any((route) => location.startsWith(route))) {
          return '/dashboard';
        }
      } else if (userRole == 'doctor') {
        // Doctor can access doctor routes
        if (!location.startsWith('/doctor/')) {
          return '/doctor/dashboard';
        }
      } else if (userRole == 'pharmacist') {
        // Pharmacist can access pharmacist routes
        if (!location.startsWith('/pharmacist/')) {
          return '/pharmacist/dashboard';
        }
      } else if (userRole == 'admin') {
        // Admin can access admin routes
        if (!location.startsWith('/admin/')) {
          return '/admin/dashboard';
        }
      }
    },
  );
});