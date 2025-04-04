import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'PixelFont',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontFamily: 'PixelFont'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AudioSettingsScreen(),
                  ),
                );
              },
              child: const Text('Audio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontFamily: 'PixelFont'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisualSettingsScreen(),
                  ),
                );
              },
              child: const Text('Visuals'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontFamily: 'PixelFont'),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    ));
  }
}

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  double masterVolume = 0.7;
  double sfxVolume = 0.8;
  double musicVolume = 0.6;
  double uiVolume = 0.7;
  bool masterEnabled = true;
  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool uiEnabled = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Audio Settings"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Audio Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            _buildVolumeSlider(
              "Master Volume", 
              masterVolume, 
              masterEnabled,
              (value) => setState(() => masterVolume = value),
              (value) => setState(() => masterEnabled = value)
            ),
            const SizedBox(height: 20),
            _buildVolumeSlider(
              "SFX Volume", 
              sfxVolume, 
              sfxEnabled,
              (value) => setState(() => sfxVolume = value),
              (value) => setState(() => sfxEnabled = value)
            ),
            const SizedBox(height: 20),
            _buildVolumeSlider(
              "Music Volume", 
              musicVolume, 
              musicEnabled,
              (value) => setState(() => musicVolume = value),
              (value) => setState(() => musicEnabled = value)
            ),
            const SizedBox(height: 20),
            _buildVolumeSlider(
              "UI Volume", 
              uiVolume, 
              uiEnabled,
              (value) => setState(() => uiVolume = value),
              (value) => setState(() => uiEnabled = value)
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildVolumeSlider(String label, double value, bool enabled, 
                           Function(double) onChanged, Function(bool) onEnabledChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: enabled,
              onChanged: (newValue) => onEnabledChanged(newValue ?? true),
            ),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Row(
          children: [
            const Text("Low", style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: value,
                onChanged: enabled ? onChanged : null,
                min: 0.0,
                max: 1.0,
              ),
            ),
            const Text("High", style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class VisualSettingsScreen extends StatefulWidget {
  const VisualSettingsScreen({super.key});

  @override
  State<VisualSettingsScreen> createState() => _VisualSettingsScreenState();
}

class _VisualSettingsScreenState extends State<VisualSettingsScreen> {
  int fontSize = 16;
  bool colorBlindMode = false;
  String colorMode = 'Standard';
  final TextEditingController _colorModeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _colorModeController.text = colorMode;
  }

  @override
  void dispose() {
    _colorModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Visual Settings"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Visual Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Text("Font Size: ", style: TextStyle(fontSize: 16)),
                SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: fontSize.toString()),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          fontSize = int.tryParse(value) ?? fontSize;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Color Blind Mode: ", style: TextStyle(fontSize: 16)),
                Checkbox(
                  value: colorBlindMode,
                  onChanged: (newValue) {
                    setState(() {
                      colorBlindMode = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Color Mode:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Text",
                  ),
                  controller: _colorModeController,
                  onChanged: (value) {
                    setState(() {
                      colorMode = value;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}