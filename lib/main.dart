import 'package:flutter/material.dart';
import 'play_audio_widget.dart';
import 'package:audio_service/audio_service.dart';

void main() {
  runApp(AudioApp());
}

class AudioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musicality',
      home: AudioServiceWidget(
          child: AudioPlayingWidget(
        kUrl:
            'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
        backgroundImage: 'images/bg_img.png',
      )),
    );
  }
}
