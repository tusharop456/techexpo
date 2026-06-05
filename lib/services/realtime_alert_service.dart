import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';


/// Model for real-time alerts received via WebSocket
class RealtimeAlert {
  final String id;
  final String childName;
  final String title;
  final String message;
  final int severity; // 0=info, 1=warning, 2=critical
  final String category;
  final DateTime timestamp;

  RealtimeAlert({
    required this.id,
    required this.childName,
    required this.title,
    required this.message,
    required this.severity,
    required this.category,
    required this.timestamp,
  });

  factory RealtimeAlert.fromJson(Map<String, dynamic> json) {
    return RealtimeAlert(
      id: json['id'] as String,
      childName: json['child_name'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as int,
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  bool get isCritical => severity == 2;
  bool get isWarning => severity == 1;
}

/// Service for real-time WebSocket alerts
class RealtimeAlertService {
  static final RealtimeAlertService _instance = RealtimeAlertService._internal();
  factory RealtimeAlertService() => _instance;
  RealtimeAlertService._internal();

  WebSocketChannel? _channel;
  final _alertController = StreamController<RealtimeAlert>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  
  // Configure your backend URL here
  static const String _backendHost = 'localhost';
  static const int _backendPort = 8000;
  static const String _parentId = 'parent_1';  // For demo

  /// Stream of incoming alerts
  Stream<RealtimeAlert> get alertStream => _alertController.stream;
  
  /// Whether WebSocket is connected
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      const wsUrl = 'ws://$_backendHost:$_backendPort/ws/alerts/$_parentId';
      debugPrint('🔌 Connecting to WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('❌ WebSocket connection closed');
          _handleDisconnect();
        },
      );
      
      _isConnected = true;
      debugPrint('✅ WebSocket connected!');
      
      // Start ping timer to keep connection alive
      _startPingTimer();
      
    } catch (e) {
      debugPrint('❌ Failed to connect WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message == 'pong') {
        // Ping response, connection is alive
        return;
      }
      
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final alert = RealtimeAlert.fromJson(data);
      
      debugPrint('🔔 Received alert: ${alert.title}');
      _alertController.add(alert);
      
    } catch (e) {
      debugPrint('Failed to parse WebSocket message: $e');
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _pingTimer?.cancel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      debugPrint('🔄 Attempting to reconnect...');
      connect();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (e) {
          debugPrint('Failed to send ping: $e');
        }
      }
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    debugPrint('🔌 WebSocket disconnected');
  }

  /// Dispose the service
  void dispose() {
    disconnect();
    _alertController.close();
  }
}

/// Global instance for easy access
final realtimeAlertService = RealtimeAlertService();
