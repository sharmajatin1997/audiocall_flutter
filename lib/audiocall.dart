import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audiocall_flutter/constant.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

const String appId = Constant.appId;

class AudioCall extends StatefulWidget {
  const AudioCall({super.key});

  @override
  State<AudioCall> createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  final String channelName = Constant.channelName;
  final String rtcToken = Constant.rtcToken;

  late RtcEngine engine;

  bool _isJoined = false;
  bool _isMuted = false;
  bool _speakerOn = false;
  bool _isTimeout = false;
  bool _isCallConnected = false;

  final List<int> _remoteUids = [];

  Timer? _ringingTimer;
  Timer? _timeoutTimer;
  Timer? _callTimer;

  String _dots = '';
  int _callSeconds = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  //==== IMPORTANT: Use unique UID ====
  final int myUid = DateTime.now().millisecondsSinceEpoch % 100000;

  @override
  void initState() {
    super.initState();

    //==== Ringing Animation on dots ====
    _ringingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_isCallConnected || _isTimeout) return;
      setState(() {
        _dots = _dots.length == 3 ? '' : '$_dots.';
      });
    });

    _startTimeout();
    _initAgora();
  }

  Future<void> _initAgora() async {
    //==== Request permissions ====
    await Permission.microphone.request();

    //==== Agora Engine ====
    engine = createAgoraRtcEngine();
    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    //==== Register event handlers ====
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (_, v) async {
          print("JOINED CHANNEL SUCCESS");
          //==== start ringing ====
          await _playRinging();
          setState(() => _isJoined = true);
        },

        //==== REMOTE USER JOINED ====
        onUserJoined: (_, uid, v) {
          if (uid == myUid) return;
          print("REMOTE USER JOINED: $uid");
          _timeoutTimer?.cancel();
          setState(() {
            if (!_remoteUids.contains(uid)) _remoteUids.add(uid);
            _isCallConnected = true;
            //==== Stop Ringing ====
            _stopRinging();
            //==== Call Timer Start ====
            _startCallTimer();
          });
        },

        onUserOffline: (_, uid, v) {
          setState(() {
            _remoteUids.remove(uid);

            if (_remoteUids.isEmpty) {
              _callTimer?.cancel();
              _isCallConnected = false;
            }
          });
        },
      ),
    );

    //==== Audio Enable ====
    await engine.enableAudio();

    //==== Join Channel ====
    await engine.joinChannel(
      token: rtcToken,
      channelId: channelName,
      uid: myUid,
      options: const ChannelMediaOptions(
        publishMicrophoneTrack: true,
        publishCameraTrack: false,
      ),
    );
  }

  void _startTimeout() {
    //==== Timer Starts for 30 seconds after that call End if user not respond====
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_isCallConnected) {
        setState(() => _isTimeout = true);
        _noResponse();
      }
    });
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callSeconds++);
    });
  }

  //==== Format Duration Of Call Timer ====
  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _playRinging() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSource(AssetSource('ring.mp3'));
    await _audioPlayer.resume();
  }

  Future<void> _stopRinging() async {
    await _audioPlayer.stop();
  }

  //==== Engine Leave and Release Methods Call ====
  Future<void> _noResponse() async {
    try {
      await engine.leaveChannel();
      await engine.release();
      await _stopRinging();
    } catch (e) {
      log(e.toString());
    }
  }

  //==== Engine Leave and Release Methods Call ====
  Future<void> _endCall() async {
    try {
      await engine.leaveChannel();
      await engine.release();
      await _stopRinging();
    } catch (e) {
      log(e.toString());
    }
    if (mounted) Navigator.pop(context);
  }

  //==== Ringing UI Methods ====
  Widget _ringingUI() {
    return _centerUI(
      title: _isJoined ? 'Ringing$_dots' : 'Connecting$_dots',
    );
  }

  //==== Call Connected UI With Timer ====
  Widget _connectedUI() {
    return _centerUI(
      title: 'Connected',
      subtitle: _formatDuration(_callSeconds),
      titleColor: Colors.greenAccent,
    );
  }

  //==== Timeout UI ====
  Widget _timeoutUI() {
    return _centerUI(
      title: 'User did not join. Please try again later..',
      showEnd: true,
    );
  }

  Widget _centerUI({
    required String title,
    String? subtitle,
    bool showEnd = false,
    Color titleColor = Colors.white70,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/user.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'John Doe',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: titleColor)),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ],
          ),
        ),
        if (showEnd)
          Positioned(
            bottom: 40,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: _endCall,
              child: const Icon(Icons.close,color: Colors.white,),
            ),
          ),
      ],
    );
  }

  //==== Audio Controls UI ====
  Widget _controls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            heroTag: "mic",
            onPressed: () {
              _isMuted = !_isMuted;
              engine.muteLocalAudioStream(_isMuted);
              setState(() {});
            },
            child: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.black,
            ),
          ),
          FloatingActionButton(
            heroTag: "speaker",
            backgroundColor: Colors.white,
            onPressed: () {
              _speakerOn = !_speakerOn;
              engine.setEnableSpeakerphone(_speakerOn);
              setState(() {});
            },
            child: Icon(
              _speakerOn ?Icons.hearing: Icons.volume_up ,
              color: Colors.black,
            ),
          ),
          FloatingActionButton(
            heroTag: "end",
            backgroundColor: Colors.red,
            onPressed: _endCall,
            child: const Icon(Icons.call_end,color: Colors.white,),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_isTimeout) _timeoutUI(),
          if (!_isTimeout && !_isCallConnected) _ringingUI(),
          if (_isCallConnected && !_isTimeout) _connectedUI(),
          if (_isJoined && !_isTimeout) _controls(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ringingTimer?.cancel();
    _timeoutTimer?.cancel();
    _callTimer?.cancel();
    _audioPlayer.dispose();
    engine.leaveChannel();
    engine.release();
    super.dispose();
  }
}
