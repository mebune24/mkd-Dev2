import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Locale provider for language switching
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void toggle() {
    state = state.languageCode == 'en' ? const Locale('fr') : const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
  }
}
