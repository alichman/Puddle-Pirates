import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitButton extends StatelessWidget {
  final double width;
  final double height;

  const ExitButton({
    super.key,
    this.width = 200,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Theme.of(context).platform == TargetPlatform.android) {
          SystemNavigator.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Press the home button to exit.")),
          );
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Center(
          child: Text(
            "Exit",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
