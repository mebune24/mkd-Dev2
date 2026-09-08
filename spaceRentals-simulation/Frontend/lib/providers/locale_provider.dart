import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(const Locale('en')),
);

class LocaleNotifier extends Notifier<Locale> {
  LocaleNotifier(this._initialLocale);

  final Locale _initialLocale;

  static Future<Locale> loadPersistedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_locale');
    return saved == 'fr' ? const Locale('fr') : const Locale('en');
  }

  @override
  Locale build() => _initialLocale;

  Future<void> toggle() async {
    final next = state.languageCode == 'en'
        ? const Locale('fr')
        : const Locale('en');
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', next.languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
  }
}
