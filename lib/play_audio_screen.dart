import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'components/duration_indicators.dart';
import 'components/play_pause_icon.dart';

typedef void OnError(Exception exception);

const kUrl =
    "https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3";

enum PlayerState { stopped, playing, paused }

class AudioPlayingWidget extends StatefulWidget {
  @override
  _AudioPlayingWidgetState createState() => _AudioPlayingWidgetState();
}

class _AudioPlayingWidgetState extends State<AudioPlayingWidget> {
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
    // TODO: change kUrl to real audio
    await audioPlayer.play(kUrl);
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
    // TODO: change kUrl
    final bytes = await _loadFileBytes(kUrl,
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
        showAlertDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 20.0),
          height: MediaQuery.of(context).copyWith().size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  PlayPauseIconButton(
                    onTap: isPlaying || isPaused ? () => stop() : null,
                    icon: Icons.stop,
                    containerSize: 55.0,
                  ),
                  PlayPauseIconButton(
                    onTap: isPlaying
                        ? () => pause()
                        : isDownloaded ? () => _playLocal() : () => play(),
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    containerSize: 70.0,
                  ),
                  PlayPauseIconButton(
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
                  inactiveTrackColor: Color(0xFF8D8E98),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white38,
                ),
                child: Slider(
                  value: position?.inMilliseconds?.toDouble() ?? 0.0,
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
              DurationIndicators(
                  position: position,
                  positionText: positionText,
                  duration: duration,
                  durationText: durationText),
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
                    isDownloaded ? Icons.check : Icons.file_download,
                    color:
                        downloadEnabled ? activeIconColor : inactiveIconColor,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        content: Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: Colors.green,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Successful download!',
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      );
    },
  );
}
