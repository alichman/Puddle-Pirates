import 'package:flutter/material.dart';
import 'package:puddle_pirates/deck_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puddle Pirates',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple), // We'll need a new theme
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [Column(), Column(), Column(), DeckPage()][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int i) => setState(() {
          currentPageIndex = i;
        }),
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Place 1"),
          NavigationDestination(icon: Icon(Icons.abc), label: "Place 2"),
          NavigationDestination(icon: Icon(Icons.build), label: "Place 3"),
          NavigationDestination(icon: Icon(Icons.build), label: "Kaelem")
        ],
      ),
    );
  }
}
