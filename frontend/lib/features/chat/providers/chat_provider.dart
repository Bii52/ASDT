import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_socket_service.dart';

// Provider cho danh sách cuộc trò chuyện
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  return ConversationsNotifier();
});

class ConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier() : super(const AsyncValue.loading()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      state = const AsyncValue.loading();
      final conversations = await ChatService.getConversations();
      state = AsyncValue.data(conversations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addConversation(Conversation conversation) {
    state.whenData((conversations) {
      final updatedConversations = [conversation, ...conversations];
      state = AsyncValue.data(updatedConversations);
    });
  }

  void updateLastMessage(String conversationId, Message message) {
    state.whenData((conversations) {
      final updatedConversations = conversations.map((conv) {
        if (conv.id == conversationId) {
          return Conversation(
            id: conv.id,
            participants: conv.participants,
            lastMessage: message,
            createdAt: conv.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return conv;
      }).toList();
      state = AsyncValue.data(updatedConversations);
    });
  }
}

// Provider cho tin nhắn trong một cuộc trò chuyện
final messagesProvider = StateNotifierProvider.family<MessagesNotifier, AsyncValue<List<Message>>, String>((ref, conversationId) {
  return MessagesNotifier(conversationId);
});

class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final String conversationId;

  MessagesNotifier(this.conversationId) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      state = const AsyncValue.loading();
      final messages = await ChatService.getMessages(conversationId);
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addMessage(Message message) {
    state.whenData((messages) {
      final updatedMessages = [...messages, message];
      state = AsyncValue.data(updatedMessages);
    });
  }

  Future<void> sendMessage(String recipientId, String content) async {
    try {
      final message = await ChatService.sendMessage(recipientId, content);
      addMessage(message);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider cho danh sách bác sĩ online
final onlineDoctorsProvider = StateProvider<List<String>>((ref) => []);

// Provider cho socket service
final chatSocketServiceProvider = Provider<ChatSocketService>((ref) {
  return ChatSocketService();
});

// Provider cho trạng thái kết nối socket
final socketConnectionProvider = StateProvider<bool>((ref) => false);
