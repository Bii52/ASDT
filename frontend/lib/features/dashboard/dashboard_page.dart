import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 1000;

    final cards = [
      _DashCard(
        title: 'Hồ sơ y tế',
        subtitle: 'BMI, chiều cao, cân nặng',
        icon: Icons.person_outline,
        color: theme.colorScheme.primary,
        onTap: () => context.push('/profile'),
      ),
      _DashCard(
        title: 'Bài viết sức khỏe',
        subtitle: 'Tin & kiến thức y khoa',
        icon: Icons.article_outlined,
        color: theme.colorScheme.tertiary,
        onTap: () => context.push('/articles'),
      ),
      _DashCard(
        title: 'Nhắc uống thuốc',
        subtitle: 'Thiết lập lịch uống',
        icon: Icons.alarm,
        color: theme.colorScheme.secondary,
        onTap: () => context.push('/reminders'),
      ),
      _DashCard(
        title: 'Sản phẩm',
        subtitle: 'Danh mục sản phẩm',
        icon: Icons.shopping_cart_outlined,
        color: theme.colorScheme.surfaceTint,
        onTap: () => context.push('/categories'),
      ),
      _DashCard(
        title: 'Chat với bác sĩ',
        subtitle: 'Tư vấn trực tuyến',
        icon: Icons.chat_bubble_outline,
        color: Colors.green,
        onTap: () => context.push('/chat'),
      ),
      _DashCard(
        title: 'Lịch hẹn',
        subtitle: 'Đặt lịch khám bệnh',
        icon: Icons.event,
        color: Colors.blue,
        onTap: () => context.push('/appointments'),
      ),
      _DashCard(
        title: 'Bác sĩ online',
        subtitle: 'Xem danh sách bác sĩ',
        icon: Icons.people_outline,
        color: Colors.blue,
        onTap: () => context.push('/chat/doctors'),
      ),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reminders/add'),
        label: const Text('Thêm nhắc'),
        icon: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // ===== Nền gradient + blobs =====
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.10),
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.25),
                    theme.colorScheme.surfaceTint.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -60,
            child: _Blob(
              size: size.width * 0.35,
              color: theme.colorScheme.primary.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -70,
            child: _Blob(
              size: size.width * 0.40,
              color: theme.colorScheme.tertiary.withValues(alpha: 0.14),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ===== Thanh tiêu đề + Profile actions =====
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _Header()),
                        const SizedBox(width: 12),
                        const _ProfileActions(),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: isWide ? const SizedBox.shrink() : const _QuickStatsRow(),
                  ),
                ),

                // ===== Lưới thẻ tính năng =====
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width >= 1200
                          ? 3
                          : size.width >= 700
                              ? 2
                              : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio:
                          size.width >= 1200 ? 1.35 : size.width >= 700 ? 1.4 : 2.4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => cards[i],
                      childCount: cards.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: c.surface.withValues(alpha: 0.65),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.primary.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.favorite, color: c.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chăm Sóc Sức Khỏe',
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Theo dõi sức khỏe, nhắc uống thuốc và đọc kiến thức y khoa mỗi ngày.',
                      style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileActions extends ConsumerWidget {
  const _ProfileActions();

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }

  Future<void> _showEditNameDialog(
      BuildContext context, WidgetRef ref, User currentUser) async {
    final nameController = TextEditingController(text: currentUser.fullName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your full name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentUser.fullName) {
      final result = await UserService.updateProfile({'fullName': newName});
      if (result['success'] == true) {
        final updatedUser = User.fromJson(result['user']);
        ref.read(authProvider.notifier).updateUser(updatedUser);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully!')),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: ${result['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clickable Avatar
          GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Uploading avatar...')),
                );
                final uploadResponse = await UserService.uploadAvatar(image);

                if (uploadResponse['success'] == true) {
                  final newAvatarUrl = uploadResponse['avatarUrl'];
                  final updateProfileResponse =
                      await UserService.updateProfile({'avatar': newAvatarUrl});

                  if (updateProfileResponse['success'] == true) {
                    final updatedUser = User.fromJson(updateProfileResponse['user']);
                    ref.read(authProvider.notifier).updateUser(updatedUser);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar updated successfully!')),
                    );
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to save avatar URL: ${updateProfileResponse['message']}',
                        ),
                      ),
                    );
                  }
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to upload avatar: ${uploadResponse['message']}'),
                    ),
                  );
                }
              }
            },
            child: CircleAvatar(
              radius: 14,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null ? const Icon(Icons.person, size: 18) : null,
            ),
          ),
          const SizedBox(width: 8),
          // Clickable Name
          GestureDetector(
            onTap: () => _showEditNameDialog(context, ref, user),
            child: Text(
              user.fullName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 2),
          // More Options Menu
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(Icons.expand_more, size: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 40),
            onSelected: (v) {
              switch (v) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'change_password':
                  context.push('/settings/change-password');
                  break;
                case 'logout':
                  _confirmLogout(context, ref);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [Icon(Icons.person_outline, color: c.primary), const SizedBox(width: 8), const Text('My Profile')],
                ),
              ),
              PopupMenuItem<String>(
                value: 'change_password',
                child: Row(
                  children: [Icon(Icons.lock_outline, color: c.primary), const SizedBox(width: 8), const Text('Change Password')],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [Icon(Icons.logout_rounded, color: c.error), const SizedBox(width: 8), const Text('Logout')],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatChip(icon: Icons.monitor_heart_rounded, label: 'BMI', value: '22.4'),
        SizedBox(width: 8),
        _StatChip(icon: Icons.alarm_on, label: 'Nhắc hôm nay', value: '2'),
        SizedBox(width: 8),
        _StatChip(icon: Icons.article, label: 'Bài viết mới', value: '3'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: 6),
          Text('$label: ', style: t.bodySmall?.copyWith(color: c.onSurfaceVariant)),
          Text(value, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DashCard extends StatefulWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DashCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: 0.12),
                  c.surface.withValues(alpha: 0.75),
                ],
              ),
              border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _hover ? 0.10 : 0.06),
                  blurRadius: _hover ? 26 : 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon trong vòng tròn mờ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: 0.14),
                    ),
                    child: Icon(widget.icon, size: 26, color: widget.color),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
