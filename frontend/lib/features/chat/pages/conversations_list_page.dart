import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/auth_service.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_page.dart';

class ConversationsListPage extends ConsumerStatefulWidget {
  const ConversationsListPage({super.key});

  @override
  ConsumerState<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends ConsumerState<ConversationsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  void _setupSocketListeners() {
    final socketService = ref.read(chatSocketServiceProvider);
    final token = ref.read(authProvider).token;
    if (token != null) {
      socketService.connect(token);
    }
    
    // Lắng nghe tin nhắn mới
    socketService.addMessageListener((Message message) {
      ref.read(conversationsProvider.notifier).updateLastMessage(
        message.conversationId,
        message,
      );
    });

    // Lắng nghe danh sách bác sĩ online
    socketService.addOnlineDoctorsListener((onlineDoctors) {
      ref.read(onlineDoctorsProvider.notifier).state = onlineDoctors;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final onlineDoctors = ref.watch(onlineDoctorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/chat/start');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(conversationsProvider.notifier).loadConversations();
            },
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có cuộc trò chuyện nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bắt đầu trò chuyện với bác sĩ',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherParticipant = conversation.participants.first;
              final isOnline = onlineDoctors.contains(otherParticipant.id);

              return ConversationTile(
                conversation: conversation,
                isOnline: isOnline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        conversation: conversation,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi khi tải danh sách cuộc trò chuyện',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(conversationsProvider.notifier).loadConversations();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isOnline;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherParticipant = conversation.participants.first;
    final lastMessage = conversation.lastMessage;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: otherParticipant.avatar != null
                ? NetworkImage(otherParticipant.avatar!)
                : null,
            child: otherParticipant.avatar == null
                ? Text(
                    otherParticipant.fullName.isNotEmpty
                        ? otherParticipant.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 18),
                  )
                : null,
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherParticipant.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : const Text('Chưa có tin nhắn'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessage != null)
            Text(
              _formatTime(lastMessage.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 4),
          if (isOnline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút';
    } else {
      return 'Vừa xong';
    }
  }
}
