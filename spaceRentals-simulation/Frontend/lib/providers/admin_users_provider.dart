import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'di_providers.dart';

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/admin/users');
  
  if (response.statusCode == 200) {
    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
});
