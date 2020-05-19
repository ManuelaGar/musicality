import 'package:flutter/material.dart';
import 'play_audio_screen.dart';
import 'package:audio_service/audio_service.dart';

void main() {
  runApp(AudioApp());
}

class AudioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musicality',
      home: AudioServiceWidget(child: AudioPlayingWidget()),
    );
  }
}
