import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/profile_screen.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/articles/articles_page.dart';
import 'features/articles/article_detail_page.dart';
import 'features/reminders/reminders_page.dart';
import 'features/reminders/add_reminder_page.dart';
import 'features/profile/edit_profile_page.dart';
import 'features/categories/categories_page.dart';

GoRouter buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/articles', builder: (_, __) => const ArticlesPage()),
      GoRoute(path: '/articles/:id', builder: (ctx, s) => ArticleDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/reminders', builder: (_, __) => const RemindersPage()),
      GoRoute(path: '/reminders/add', builder: (_, __) => const AddReminderPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
      GoRoute(path: '/categories', builder: (_, __) => CategoriesPage()),
    ],
  );
}
