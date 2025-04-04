import 'package:flutter/material.dart';

class PixelButton extends StatelessWidget {
  final String text;
  final String? route; // Make route optional
  final Color color;
  final double width;
  final double height;
  final VoidCallback? onTap; // Add onTap callback

  const PixelButton({
    super.key,
    required this.text,
    this.route,
    this.onTap,
    this.color = const Color(0xFF1565C0),
    this.width = 200,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (route != null) {
          Navigator.pushNamed(context, route!);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: "PixelFont",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
