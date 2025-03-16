import 'package:flutter/material.dart';

class SavedGamesScreen extends StatelessWidget {
  const SavedGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Saved Games"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Load Game',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 4, // Placeholder for saved games
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Game Save ${index + 1}"),
                  subtitle: const Text("Some date/time"),
                  onTap: () => Navigator.pushNamed(context, '/game_page'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}