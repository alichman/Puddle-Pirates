import 'package:flutter/material.dart';

class PixelButton extends StatelessWidget {
  final String text;
  final String route;
  final Color color;
  final double width;
  final double height;

  const PixelButton({
    super.key,
    required this.text,
    required this.route,
    this.color = const Color(0xFF1565C0),
    this.width = 200,
    this.height = 50,
  });
  

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3),
          ),      
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: "PixelFont",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
    );
  }
}
