import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/pages/chat_detail_page.dart';
import '../../chat/providers/chat_provider.dart';

class DoctorChatsPage extends ConsumerStatefulWidget {
  const DoctorChatsPage({super.key});

  @override
  ConsumerState<DoctorChatsPage> createState() => _DoctorChatsPageState();
}

class _DoctorChatsPageState extends ConsumerState<DoctorChatsPage> {
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn với bệnh nhân'),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('Chưa có cuộc trò chuyện nào.'));
          }
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherParticipant = conversation.participants.first;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(otherParticipant.fullName.isNotEmpty
                      ? otherParticipant.fullName[0].toUpperCase()
                      : '?'),
                ),
                title: Text(otherParticipant.fullName),
                subtitle: Text(conversation.lastMessage?.content ?? 'Bắt đầu trò chuyện'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(conversation: conversation),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi tải tin nhắn: $error')),
      ),
    );
  }
}
