import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_endpoints.dart';
import '../providers/di_providers.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get<dynamic>(ApiEndpoints.notifications);
  if (response.data == null) return [];
  final data = response.data as Map<String, dynamic>;
  final list = data['data'] as List<dynamic>? ?? [];
  return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
});
