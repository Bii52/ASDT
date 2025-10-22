import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/articles/articles_page.dart';
import 'features/articles/article_detail_page.dart';
import 'features/reminders/reminders_page.dart';
import 'features/reminders/add_reminder_page.dart';
import 'features/profile/profile_page.dart';
import 'features/profile/edit_profile_page.dart';

GoRouter buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/articles', builder: (_, __) => const ArticlesPage()),
      GoRoute(path: '/articles/:id', builder: (ctx, s) => ArticleDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/reminders', builder: (_, __) => const RemindersPage()),
      GoRoute(path: '/reminders/add', builder: (_, __) => const AddReminderPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
    ],
  );
}
