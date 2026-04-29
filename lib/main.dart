import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pip_view/pip_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const VLCPlayerApp());
}

class VLCPlayerApp extends StatelessWidget {
  const VLCPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacu Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController(
    text: 'http://datahub11.com/live/76446885500/86436775522/9399.ts',
  );
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  bool _isPlaying = false;
  String? _error;
  double _volume = 100.0;

  @override
  void initState() {
    super.initState();
    player.stream.error.listen((error) {
      setState(() {
        _error = error.toString();
      });
    });
    player.stream.volume.listen((value) {
      setState(() {
        _volume = value;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _playUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isPlaying = true;
      _error = null;
    });

    try {
      await player.open(Media(url));
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PIPView(
      builder: (context, isFloating) {
        if (isFloating) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Video(controller: controller, controls: NoVideoControls),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Background Gradient Orbs
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.withOpacity(0.3),
                  ),
                ).animate().fadeIn(duration: 2.seconds).scale(begin: const Offset(0.5, 0.5)),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ).animate().fadeIn(duration: 2.seconds).scale(begin: const Offset(0.5, 0.5)),
              ),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurpleAccent.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.play_circle_filled_rounded, size: 32, color: Colors.white),
                              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hacu Player',
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'VLC-Style Streamer',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                            ],
                          ),
                          if (_isPlaying)
                            IconButton(
                              onPressed: () {
                                PIPView.of(context)?.presentPipHighlight();
                                // Simple way to trigger PipView's floating mode
                                // For pip_view, we usually push a new screen or use its internal state
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PIPView(
                                      builder: (context, isFloating) => Scaffold(
                                        backgroundColor: Colors.black,
                                        body: Video(controller: controller, controls: NoVideoControls),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white),
                              tooltip: 'Enter PiP Mode',
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // URL Input Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                hintText: 'Paste any media link here...',
                                hintStyle: const TextStyle(color: Colors.white30),
                                prefixIcon: const Icon(Icons.link_rounded, color: Colors.deepPurpleAccent),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white30),
                                  onPressed: () => _urlController.clear(),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.4),
                                contentPadding: const EdgeInsets.all(20),
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            const SizedBox(height: 24),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _playUrl,
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.deepPurpleAccent, Colors.blueAccent],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurpleAccent.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'LAUNCH PLAYER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 40),

                      // Volume Control (VLC Style)
                      if (_isPlaying)
                        Row(
                          children: [
                            const Icon(Icons.volume_up_rounded, color: Colors.white70),
                            Expanded(
                              child: Slider(
                                value: _volume,
                                min: 0,
                                max: 100,
                                onChanged: (value) {
                                  player.setVolume(value);
                                },
                                activeColor: Colors.deepPurpleAccent,
                              ),
                            ),
                            Text('${_volume.toInt()}%', style: const TextStyle(color: Colors.white70)),
                          ],
                        ).animate().fadeIn(),

                      const SizedBox(height: 12),

                      // Player Viewport
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isPlaying)
                                Video(
                                  controller: controller,
                                  controls: MaterialVideoControls,
                                )
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.video_library_rounded,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Ready to play any link',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white30,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(duration: 800.ms),
                              
                              if (_error != null)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.9),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Playback Error: $_error',
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                                          onPressed: () => setState(() => _error = null),
                                        ),
                                      ],
                                    ),
                                  ).animate().slideY(begin: 1),
                                ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.98, 0.98)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
