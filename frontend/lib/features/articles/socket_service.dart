import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// TODO: Di chuyển vào tệp cấu hình
const String socketUrl = 'http://10.0.2.2:5000';

class SocketService {
  io.Socket? _socket;

  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? get socket => _socket;

  void connect(String authToken) {
    // Ngắt kết nối cũ nếu có
    disconnect();

    // Khởi tạo kết nối mới
    // Sử dụng 10.0.2.2 cho Android emulator
    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'path': '/socket.io', // Đảm bảo path khớp với server
      'auth': {
        'token': authToken, // Gửi token để xác thực
      }
    });

    _socket!.onConnect((_) {
      debugPrint('Socket connected: ${_socket!.id}');
    });

    _socket!.on('online_doctors_update', (data) {
      debugPrint('Online doctors: $data');
      // TODO: Sử dụng một StateNotifierProvider (Riverpod) để giữ danh sách bác sĩ
      // và thông báo cho UI cập nhật.
    });

    _socket!.onDisconnect((_) => debugPrint('Socket disconnected'));
    _socket!.onConnectError((data) => debugPrint('Connection Error: $data'));
    _socket!.onError((data) => debugPrint('Socket Error: $data'));
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}