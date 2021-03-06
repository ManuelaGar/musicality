import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class PlayingControls extends StatelessWidget {
  final bool isPlaying;
  final LoopMode loopMode;
  final bool isPlaylist;
  final Function() onPrevious;
  final Function() onPlay;
  final Function() onNext;
  final Function() toggleLoop;
  final Function() onStop;

  PlayingControls({
    @required this.isPlaying,
    this.isPlaylist = false,
    this.loopMode,
    this.toggleLoop,
    this.onPrevious,
    @required this.onPlay,
    this.onNext,
    this.onStop,
  });

  Widget _loopIcon(BuildContext context) {
    final iconSize = 34.0;
    if (loopMode == LoopMode.none) {
      return Icon(
        Icons.loop,
        size: iconSize,
        color: Colors.grey,
      );
    } else if (loopMode == LoopMode.playlist) {
      return Icon(
        Icons.loop,
        size: iconSize,
        color: Colors.black,
      );
    } else {
      //single
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.loop,
            size: iconSize,
            color: Colors.black,
          ),
          Center(
            child: Text(
              "1",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        NeumorphicButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
          ),
          padding: EdgeInsets.all(24),
          onPressed: this.onPlay,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 32,
          ),
        ),
        SizedBox(
          width: 45,
        ),
        if (onStop != null)
          NeumorphicButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
            padding: EdgeInsets.all(16),
            onPressed: this.onStop,
            child: Icon(
              Icons.stop,
              size: 32,
            ),
          ),
      ],
    );
  }
}
