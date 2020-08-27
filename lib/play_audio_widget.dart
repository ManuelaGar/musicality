import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'components/audio_duration_indicators.dart';
import 'components/audio_icon_button.dart';
import 'components/show_alert.dart';

typedef void OnError(Exception exception);

/*const kUrl =
    "https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3";*/

enum PlayerState { stopped, playing, paused }

class AudioPlayingWidget extends StatefulWidget {
  AudioPlayingWidget({@required this.kUrl, @required this.backgroundImage});

  final kUrl;
  final backgroundImage;

  @override
  _AudioPlayingWidgetState createState() => _AudioPlayingWidgetState();
}

class _AudioPlayingWidgetState extends State<AudioPlayingWidget> {
  String songUrl;
  String bgImage;

  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);

  AudioPlayer audioPlayer;
  String localFilePath;

  Color activeIconColor = Colors.white;
  Color inactiveIconColor = Colors.white70;

  bool downloadEnabled = true;
  bool isDownloaded = false;
  bool isMuted = false;

  PlayerState playerState = PlayerState.stopped;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    songUrl = widget.kUrl;
    bgImage = widget.backgroundImage;

    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(songUrl);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future _playLocal() async {
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future _loadFile() async {
    final bytes = await _loadFileBytes(songUrl,
        onError: (Exception exception) =>
            print('_loadFile => exception $exception'));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        localFilePath = file.path;
        isDownloaded = true;
        downloadEnabled = true;
        _playLocal();
        showAlertDialog(context, 'Successful download!');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 30.0),
          height: 280,
          decoration: BoxDecoration(
            color: Color(0xFF1D1E33).withOpacity(0.4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(top: 10.0),
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: isDownloaded
                      ? null
                      : () {
                          _loadFile();
                          setState(() {
                            downloadEnabled = false;
                          });
                        },
                  child: Icon(
                    isDownloaded ? Icons.cloud_done : Icons.cloud_download,
                    color:
                        downloadEnabled ? activeIconColor : inactiveIconColor,
                    size: 25.0,
                  ),
                ),
              ),
              Text(
                'currentRecording',
                textAlign: TextAlign.center,
                style: /*kMusicTextStyle*/ TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                'currentPhase',
                textAlign: TextAlign.center,
                style: /*kLabelTextStyle*/ TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFECEFF0),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  AudioIconButton(
                    onTap: isPlaying || isPaused ? () => stop() : null,
                    icon: Icons.stop,
                    containerSize: 55.0,
                  ),
                  AudioIconButton(
                    onTap: isPlaying
                        ? () => pause()
                        : isDownloaded ? () => _playLocal() : () => play(),
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    containerSize: 70.0,
                  ),
                  AudioIconButton(
                    onTap:
                        isMuted == false ? () => mute(true) : () => mute(false),
                    icon: isMuted == false ? Icons.headset : Icons.headset_off,
                    containerSize: 55.0,
                  ),
                ]),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white38,
                  trackHeight: 3.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 13.0),
                  thumbColor: Color(0xFFE9EAFF),
                  overlayColor: Color(0xFFE9EAFF).withOpacity(0.4),
                ),
                child: Slider(
                  value: duration > position
                      ? position?.inMilliseconds?.toDouble()
                      : 0.0,
                  onChanged: (double value) {
                    Duration pos = Duration(
                        seconds: (value / 1000).roundToDouble().toInt());
                    setState(() {
                      position = pos;
                      audioPlayer.seek((value / 1000).roundToDouble());
                    });
                  },
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble(),
                ),
              ),
              AudioDurationIndicators(
                position: position,
                positionText: positionText,
                duration: duration,
                durationText: durationText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
