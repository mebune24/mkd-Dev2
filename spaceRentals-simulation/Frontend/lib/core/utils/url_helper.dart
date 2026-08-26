import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility for launching URLs with automatic fallback handling.
/// Handles the case where WhatsApp is not installed by falling back
/// to the WhatsApp web URL.
class UrlHelper {
  static const _whatsappGroupUrl =
      'https://chat.whatsapp.com/JoffOh0nVQr4maaqFPdsex?s=cl&p=a&ilr=4';

  /// Launch a WhatsApp group/chat link.
  /// Tries launchUrl directly (without canLaunchUrl gate) because
  /// on Android 11+ canLaunchUrl returns false due to package visibility
  /// restrictions even when WhatsApp IS installed.
  static Future<void> openWhatsApp(
    BuildContext context, [
    String? url,
  ]) async {
    final target = url ?? _whatsappGroupUrl;
    final uri = Uri.parse(target);

    try {
      // Try direct launch first — WhatsApp registers as intent handler
      // for chat.whatsapp.com so the OS will route it to WhatsApp if installed.
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // fall through
    }

    // Fallback: convert to web.whatsapp.com for browser
    final webUrl = target.replaceFirst(
        'chat.whatsapp.com', 'web.whatsapp.com');
    final webUri = Uri.parse(webUrl);

    try {
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // fall through
    }

    // Last resort: plain browser
    try {
      await launchUrl(
        Uri.parse('https://www.whatsapp.com'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open WhatsApp. Please install it from the Play Store.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Launch any URL, with a snackbar fallback on failure.
  static Future<void> launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {
      // fall through
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open: $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
