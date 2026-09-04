import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A singleton Socket.io service that manages the real-time connection.
/// The frontend connects using the JWT token so the backend can identify the user.
class SocketService {
  static SocketService? _instance;
  static SocketService get instance => _instance ??= SocketService._();
  SocketService._();

  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Connect to the socket server with a JWT token.
  void connect(String token) {
    if (_isConnected) return;

    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.194:3000';

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print('[Socket] Connected ✓');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('[Socket] Disconnected');
    });

    _socket!.onConnectError((err) {
      print('[Socket] Connection error: $err');
    });

    _socket!.connect();
  }

  /// Disconnect from the socket server.
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  /// Join a chat room by roomId.
  void joinRoom(String roomId) {
    _socket?.emit('join_room', roomId);
  }

  /// Send a message in a room.
  void sendMessage({
    required String roomId,
    required String message,
    required String receiverId,
  }) {
    _socket?.emit('send_message', {
      'roomId': roomId,
      'message': message,
      'receiverId': receiverId,
    });
  }

  /// Listen for incoming messages in a room.
  void onMessage(void Function(Map<String, dynamic> data) handler) {
    _socket?.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        handler(data);
      } else if (data is Map) {
        handler(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Remove the message listener (call on screen dispose).
  void offMessage() {
    _socket?.off('new_message');
  }

  /// Listen for notifications.
  void onNotification(void Function(Map<String, dynamic> data) handler) {
    _socket?.on('notification', (data) {
      if (data is Map) handler(Map<String, dynamic>.from(data));
    });
  }
}

/// Riverpod provider to access the SocketService.
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService.instance;
});
