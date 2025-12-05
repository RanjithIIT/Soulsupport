import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeChatService {
  final String baseWsUrl; // e.g. ws://localhost:8000
  WebSocketChannel? _channel;

  RealtimeChatService({required this.baseWsUrl});

  Stream<dynamic>? get stream => _channel?.stream;

  void connect({required String roomId}) {
    final uri = Uri.parse('$baseWsUrl/ws/teacher-parent/$roomId/');
    _channel = WebSocketChannel.connect(uri);
  }

  void sendMessage({required String sender, required String message}) {
    _channel?.sink.add(jsonEncode({
      'sender': sender,       // "teacher" or "parent"
      'message': message,
    }));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}