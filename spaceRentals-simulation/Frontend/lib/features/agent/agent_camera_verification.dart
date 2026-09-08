import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AgentCameraVerificationScreen extends StatefulWidget {
  const AgentCameraVerificationScreen({super.key});

  @override
  State<AgentCameraVerificationScreen> createState() => _AgentCameraVerificationScreenState();
}

class _AgentCameraVerificationScreenState extends State<AgentCameraVerificationScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isReady = false;
  
  // Simulated accelerometer data for the leveling guide
  double _pitch = 0.0;
  double _roll = 0.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _simulateSensors();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) setState(() => _isReady = true);
      }
    } catch (e) {
      debugPrint('Camera init error: \$e');
    }
  }

  // Simulate gyro/accelerometer changing slightly
  void _simulateSensors() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _pitch = math.sin(DateTime.now().millisecondsSinceEpoch / 1000) * 15;
        _roll = math.cos(DateTime.now().millisecondsSinceEpoch / 1000) * 15;
      });
      _simulateSensors();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _isLevel() {
    return _pitch.abs() < 5.0 && _roll.abs() < 5.0;
  }

  Future<void> _takePicture() async {
    if (!_isLevel()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please hold the phone level to take a quality photo.')),
      );
      HapticFeedback.vibrate();
      return;
    }
    
    try {
      HapticFeedback.heavyImpact();
      final image = await _controller!.takePicture();
      // Handle the image file
      Navigator.pop(context, image.path);
    } catch (e) {
      debugPrint('Error taking picture: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final isLevel = _isLevel();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview
          CameraPreview(_controller!),
          
          // 2. Dark Overlay for Framing
          CustomPaint(
            painter: _FramingOverlayPainter(
              isLevel: isLevel,
              pitch: _pitch,
              roll: _roll,
              accentColor: theme.colorScheme.primary,
            ),
          ),
          
          // 3. UI Elements
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLevel ? 'Perfect Framing' : 'Hold device level',
                          style: TextStyle(
                            color: isLevel ? Colors.greenAccent : Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                
                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    children: [
                      const Text(
                        'Align the crosshairs to ensure photo quality',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _takePicture,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLevel ? Colors.greenAccent : Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isLevel ? Colors.greenAccent : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FramingOverlayPainter extends CustomPainter {
  final bool isLevel;
  final double pitch;
  final double roll;
  final Color accentColor;

  _FramingOverlayPainter({
    required this.isLevel,
    required this.pitch,
    required this.roll,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dim the outside of the framing box
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final rectWidth = size.width * 0.85;
    final rectHeight = size.height * 0.6;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2;
    final clearRect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    
    // Draw outer dark overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(clearRect, const Radius.circular(16))),
      ),
      darkPaint,
    );

    // Draw the framing box border
    final borderPaint = Paint()
      ..color = isLevel ? Colors.greenAccent : Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(clearRect, const Radius.circular(16)), borderPaint);

    // Draw Grid Lines (Rule of Thirds)
    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    
    // Vertical lines
    canvas.drawLine(Offset(left + rectWidth / 3, top), Offset(left + rectWidth / 3, top + rectHeight), gridPaint);
    canvas.drawLine(Offset(left + (rectWidth * 2) / 3, top), Offset(left + (rectWidth * 2) / 3, top + rectHeight), gridPaint);
    
    // Horizontal lines
    canvas.drawLine(Offset(left, top + rectHeight / 3), Offset(left + rectWidth, top + rectHeight / 3), gridPaint);
    canvas.drawLine(Offset(left, top + (rectHeight * 2) / 3), Offset(left + rectWidth, top + (rectHeight * 2) / 3), gridPaint);

    // Draw Leveling Crosshairs
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Fixed center cross
    final fixedCrossPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;
    canvas.drawLine(Offset(centerX - 15, centerY), Offset(centerX + 15, centerY), fixedCrossPaint);
    canvas.drawLine(Offset(centerX, centerY - 15), Offset(centerX, centerY + 15), fixedCrossPaint);

    // Moving indicator (based on pitch and roll)
    final indicatorPaint = Paint()
      ..color = isLevel ? Colors.greenAccent : Colors.amberAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    // Map pitch and roll to pixels (simple linear mapping for visual feedback)
    final dx = (roll / 30) * 50; 
    final dy = (pitch / 30) * 50;
    
    canvas.drawCircle(Offset(centerX + dx, centerY + dy), 10, indicatorPaint);
    if (isLevel) {
      canvas.drawCircle(Offset(centerX + dx, centerY + dy), 4, Paint()..color = Colors.greenAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _FramingOverlayPainter oldDelegate) {
    return oldDelegate.pitch != pitch || oldDelegate.roll != roll || oldDelegate.isLevel != isLevel;
  }
}
