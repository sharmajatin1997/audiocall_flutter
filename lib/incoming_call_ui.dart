import 'dart:ui';
import 'package:audiocall_flutter/audiocall.dart';
import 'package:audiocall_flutter/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingCallUI extends StatefulWidget {
  final String callerName;

  const IncomingCallUI({super.key, required this.callerName});

  @override
  State<IncomingCallUI> createState() => _IncomingCallUIState();
}

class _IncomingCallUIState extends State<IncomingCallUI>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulse;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _playRingtone();
  }

  /// 🔊 Play ringtone
  Future<void> _playRingtone() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSource(AssetSource('caller_tune.mp3'));
    await _audioPlayer.resume();
  }

  /// ⏹ Stop ringtone
  Future<void> _stopRingtone() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _stopRingtone();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _rippleAvatar(double radius) {
    return SizedBox(
      width: radius * 3,
      height: radius * 3,
      child: AnimatedBuilder(
        animation: _rippleController,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _ripple(radius, 0),
              _ripple(radius, 0.35),
              _ripple(radius, 0.7),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: radius,
                  backgroundImage: const AssetImage('assets/user.png'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ripple(double radius, double delay) {
    final value = (_rippleController.value + delay) % 1;
    final size = radius * 2 + value * radius * 1.8;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.35 * (1 - value)),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double size,
  }) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    final avatarRadius = width * 0.18;
    final buttonSize = width * 0.18;

    return Scaffold(
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: height * 0.1),
                _rippleAvatar(avatarRadius),
                SizedBox(height: height * 0.03),
                Text(
                  widget.callerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.065,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Incoming Audio Call',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: height * 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        size: buttonSize,
                        onTap: () async {
                          await _stopRingtone();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CallScreen(),
                            ),
                          );
                        },
                      ),
                      _actionButton(
                        icon: Icons.call,
                        color: Colors.green,
                        size: buttonSize,
                        onTap: () async {
                          await _stopRingtone();
                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AudioCall()),
                          );

                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
