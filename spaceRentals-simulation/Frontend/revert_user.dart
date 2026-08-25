import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Undo UserProfile
    if (content.contains('UserProfile')) {
      content = content.replaceAll('UserProfile', 'UserModel');
      modified = true;
    }
    if (content.contains("import '../../features/profile/domain/user_profile.dart';")) {
      content = content.replaceAll("import '../../features/profile/domain/user_profile.dart';", "import '../../models/user_model.dart';");
      modified = true;
    }
    if (content.contains("import '../features/profile/domain/user_profile.dart';")) {
      content = content.replaceAll("import '../features/profile/domain/user_profile.dart';", "import '../models/user_model.dart';");
      modified = true;
    }

    // Fix remaining property.id to property.property.id that were missed in ListingsScreen
    if (content.contains('property.id') && content.contains('PropertyWithListing') && !content.contains('property.property.id') && file.path.contains('listings_screen.dart')) {
      content = content.replaceAll('property.id', 'property.property.id');
      modified = true;
    }
    
    // AuthNotifier missing methods
    if (content.contains('authProvider.notifier).register(')) {
      content = content.replaceAll('authProvider.notifier).register(', 'authProvider.notifier).signUp(');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Reverted/Fixed ${file.path}');
    }
  }
}
