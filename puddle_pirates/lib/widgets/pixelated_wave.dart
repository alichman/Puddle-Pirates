import 'package:flutter/material.dart';
import 'dart:math' as math;

class PixelatedWave extends StatefulWidget {
  final double height;
  final List<Color> waveColors;
  final double pixelSize;

  const PixelatedWave({
    super.key,
    this.height = 100,
    this.pixelSize = 8,
    this.waveColors = const [
      Color.fromARGB(255, 8, 84, 146),    // Deepest
      Color.fromARGB(255, 30, 105, 180),  // Mid
      Color.fromARGB(255, 55, 145, 219),  // Shallow
      Color.fromARGB(255, 120, 185, 255), // Lightest
    ],
  });

  @override
  State<PixelatedWave> createState() => _PixelatedWaveState();
}

class _PixelatedWaveState extends State<PixelatedWave> with TickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: PixelatedWavePainter(
              animation: _waveController,
              pixelSize: widget.pixelSize,
              waveColors: widget.waveColors,
            ),
            size: Size(double.infinity, widget.height),
          );
        },
      ),
    );
  }
}

// Pixelated Wave Painter
class PixelatedWavePainter extends CustomPainter {
  final Animation<double> animation;
  final double pixelSize;
  final List<Color> waveColors;

  PixelatedWavePainter({
    required this.animation,
    required this.pixelSize,
    required this.waveColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelsHorizontal = (size.width / pixelSize).ceil();

    for (int layer = 0; layer < waveColors.length; layer++) {
      final paint = Paint()..color = Color.fromRGBO(
          waveColors[layer].red,
          waveColors[layer].green,
          waveColors[layer].blue,
          1 - (layer * 0.2),
        );

      for (int x = 0; x < pixelsHorizontal; x++) {
        final waveHeight = size.height * (0.3 + layer * 0.1) +
            math.sin((x * pixelSize / (25 + layer * 10)) + animation.value * 2 * math.pi) * (8 + layer * 4);

        final top = size.height - waveHeight;

        if (top < size.height) {
          final rect = Rect.fromLTWH(
            x * pixelSize,
            top - (top % pixelSize), // Snap to pixel grid
            pixelSize,
            size.height,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PixelatedWavePainter oldDelegate) => true;
}
