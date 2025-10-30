import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;


const String socketUrl = 'http://192.168.1.19:5000';

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

  
    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'path': '/socket.io', 
      'auth': {
        'token': authToken, 
      }
    });

    _socket!.onConnect((_) {
      debugPrint('Socket connected: ${_socket!.id}');
    });

    _socket!.on('online_doctors_update', (data) {
      debugPrint('Online doctors: $data');

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