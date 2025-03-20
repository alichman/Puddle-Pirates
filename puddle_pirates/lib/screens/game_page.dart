import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Page"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back to Main Menu"),
        ),
      ),
    );
  }
}
