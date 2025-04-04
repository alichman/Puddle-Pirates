import 'package:flutter/material.dart';
import '../widgets/pixel_button.dart';
import '../widgets/exit_button.dart';
import '../widgets/pixelated_wave.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        /*
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        */
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/oceanMenu.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Title positioned in the Stack with better positioning control
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 20), // Add some padding to ensure text isn't cut off
              child: Column(
                children: [
                  // For "Puddle" text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        "Puddle",
                        style: Theme.of(context).textTheme.displayLarge
                      ),
                    ),
                  ),
                  // Negative spacing effect achieved with Transform
                  Transform.translate(
                    offset: const Offset(0, -20), // Move up by 20 pixels
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40), // Padding from right side
                        child: Text(
                          "Pirates",
                          style: Theme.of(context).textTheme.displayLarge
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Pixelated Wave Animation
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PixelatedWave(
              height: 100,
              pixelSize: 8,
            ),
          ),
          
          // Menu Buttons - moved lower and made smaller
          Positioned(
            bottom: 80, // Lower position from the bottom of the screen
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    PixelButton(
                      text: "New Game",
                      route: '/game_creation',
                      width: 180,
                    ),
                    SizedBox(width: 20),
                    PixelButton(
                      text: "Load Game",
                      route: '/saved_games',
                      width: 180,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const PixelButton(
                  text: "Library",
                  route: '/card_library',
                  width: 180,
                ),
                const SizedBox(height: 20),
                const ExitButton(
                  width: 180,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
