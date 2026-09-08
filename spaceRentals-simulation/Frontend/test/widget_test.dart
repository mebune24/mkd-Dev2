import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_rentals/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists and restores the selected locale globally', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'fr'});
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith(() => LocaleNotifier(const Locale('fr'))),
      ],
    );

    addTearDown(container.dispose);

    expect(container.read(localeProvider).languageCode, 'fr');
    await container.read(localeProvider.notifier).setLocale(const Locale('en'));
    expect(container.read(localeProvider).languageCode, 'en');
  });
}
