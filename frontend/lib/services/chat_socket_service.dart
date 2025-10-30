import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../features/chat/models/conversation.dart';

const String socketUrl = 'http://192.168.1.83:5000';

class ChatSocketService {
  io.Socket? _socket;
  final List<Function(Message)> _messageListeners = [];
  final List<Function(List<String>)> _onlineDoctorsListeners = [];

  // Singleton pattern
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  io.Socket? get socket => _socket;

  void connect(String authToken) {
    // Ngắt kết nối cũ nếu có
    disconnect();

    print('=== Socket Connection Debug ===');
    print('Socket URL: $socketUrl');
    print('Token length: ${authToken.length}');
    print('Token preview: ${authToken.substring(0, 20)}...');

    // Khởi tạo kết nối mới
    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'path': '/socket.io', 
      'auth': {
        'token': authToken, 
      }
    });

    _socket!.onConnect((_) {
      print('✓ Chat Socket connected successfully: ${_socket!.id}');
    });

    _socket!.onConnectError((data) {
      print('✗ Chat Connection Error: $data');
    });

    _socket!.onError((data) {
      print('✗ Chat Socket Error: $data');
    });

    _socket!.onDisconnect((reason) {
      print('Chat Socket disconnected: $reason');
    });

    // Lắng nghe tin nhắn mới
    _socket!.on('new_message', (data) {
      print('New message received: $data');
      final message = Message.fromJson(data);
      for (final listener in _messageListeners) {
        listener(message);
      }
    });

    // Lắng nghe danh sách bác sĩ online
    _socket!.on('online_doctors_update', (data) {
      print('✓ Online doctors received: $data');
      final onlineDoctors = List<String>.from(data);
      for (final listener in _onlineDoctorsListeners) {
        listener(onlineDoctors);
      }
    });

    print('Socket connection initiated...');
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  /// Thêm listener cho tin nhắn mới
  void addMessageListener(Function(Message) listener) {
    _messageListeners.add(listener);
  }

  /// Xóa listener cho tin nhắn mới
  void removeMessageListener(Function(Message) listener) {
    _messageListeners.remove(listener);
  }

  /// Thêm listener cho danh sách bác sĩ online
  void addOnlineDoctorsListener(Function(List<String>) listener) {
    _onlineDoctorsListeners.add(listener);
  }

  /// Xóa listener cho danh sách bác sĩ online
  void removeOnlineDoctorsListener(Function(List<String>) listener) {
    _onlineDoctorsListeners.remove(listener);
  }

  /// Gửi tin nhắn qua socket (optional - có thể dùng API thay thế)
  void sendMessage(String recipientId, String content) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', {
        'recipientId': recipientId,
        'content': content,
      });
    }
  }
}
