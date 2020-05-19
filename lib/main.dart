import 'package:flutter/material.dart';
import 'audio_paying_widget.dart';

void main() {
  runApp(AudioApp());
}

class AudioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musicality',
      home: AudioPlayingWidget(),
    );
  }
}
