import 'package:flutter/material.dart';

class AnimatedLoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final ButtonStyle? style;

  const AnimatedLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  State<AnimatedLoadingButton> createState() => _AnimatedLoadingButtonState();
}

class _AnimatedLoadingButtonState extends State<AnimatedLoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: widget.style,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            : widget.child,
      ),
    );
  }
}
