import 'package:flutter/material.dart';

class LogoWatermark extends StatelessWidget {
  const LogoWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: 0.045,
          child: Image.asset(
            'assets/images/logo.png',
            width: 230,
            height: 230,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
