import 'package:flutter/material.dart';

/// A wrapper widget for modals/forms to prevent accidental dismissal
/// when the user has unsaved changes.
///
/// Wraps the child in a [PopScope]. If [hasUnsavedChanges] is true,
/// attempting to pop (via back button or barrier tap) will show an alert
/// dialog confirming if the user wants to discard changes.
class FormSafeModal extends StatelessWidget {
  final Widget child;
  final bool hasUnsavedChanges;
  
  /// Optional custom title for the discard dialog.
  final String discardTitle;
  
  /// Optional custom message for the discard dialog.
  final String discardMessage;

  const FormSafeModal({
    super.key,
    required this.child,
    required this.hasUnsavedChanges,
    this.discardTitle = 'Discard changes?',
    this.discardMessage = 'You have unsaved changes. Are you sure you want to discard them?',
  });

  Future<bool> _onWillPop(BuildContext context) async {
    if (!hasUnsavedChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(discardTitle),
        content: Text(discardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: child,
    );
  }
}
