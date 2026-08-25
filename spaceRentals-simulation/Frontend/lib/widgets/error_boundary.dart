import 'package:flutter/material.dart';

/// A reusable error boundary widget. In Flutter, widget tree errors
/// are caught globally via [ErrorWidget.builder]. Call [setupGlobalErrorHandling]
/// in main() to replace the Red Screen of Death with a friendly UI.
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Installs a global custom error widget builder that catches rendering errors
/// and displays a user-friendly error screen instead of the red screen of death.
void setupGlobalErrorHandling() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  };
}
