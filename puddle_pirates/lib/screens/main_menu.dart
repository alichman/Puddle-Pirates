import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Puddle Pirates"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/game_creation'),
              child: const Text("New Game"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/saved_games'),
              child: const Text("Load Game"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/card_library'),
              child: const Text("Library"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Exit the app on Android
                if (Theme.of(context).platform == TargetPlatform.android) {
                  SystemNavigator.pop(); // Close the app on Android
                } else {
                  // Show a message for iOS
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Press the home button to exit the app."),
                    ),
                  );
                }
              },
              child: const Text("Exit"),
            ),
          ],
        ),
      ),
    );
  }
}