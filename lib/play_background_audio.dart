import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'playing_controls.dart';
import 'position_seek_widget.dart';

class PlayBackgroundAudio extends StatefulWidget {
  @override
  _PlayBackgroundAudioState createState() => _PlayBackgroundAudioState();
}

class _PlayBackgroundAudioState extends State<PlayBackgroundAudio> {
  final audios = <Audio>[
    Audio.network(
      "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3",
      metas: Metas(
        id: "Online",
        title: "Online",
        artist: "Florent Champigny",
        album: "OnlineAlbum",
        image: MetasImage.network(
            "https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg"),
      ),
    ),
    Audio.network(
      'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
      //playSpeed: 2.0,
      metas: Metas(
        id: "Rock",
        title: "Rock",
        artist: "Florent Champigny",
        album: "RockAlbum",
        image: MetasImage.network(
            "https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png"),
      ),
    ),
  ];

  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId("music");
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print("audioSessionId : $sessionId");
    }));
    _subscriptions.add(_assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    }));
    _subscriptions.add(_assetsAudioPlayer.onReadyToPlay.listen((audio) {
      print("onReadyToPlay : $audio");
    }));
    _subscriptions.add(_assetsAudioPlayer.playerState.listen((playerState) {
      print("playerState : $playerState");
    }));
    _subscriptions.add(_assetsAudioPlayer.isPlaying.listen((isplaying) {
      print("isplaying : $isplaying");
    }));
    _subscriptions
        .add(AssetsAudioPlayer.addNotificationOpenAction((notification) {
      return false;
    }));

    _assetsAudioPlayer.open(
      Audio.network(
        "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3",
        metas: Metas(
          id: "Online",
          title: "Online",
          artist: "Florent Champigny",
          album: "OnlineAlbum",
          image: MetasImage.network(
              "https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg"),
        ),
      ),
      showNotification: true,
      notificationSettings: NotificationSettings(
        prevEnabled: false, //disable the previous button
        nextEnabled: false,
      ),
      headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplugPlayOnPlug,
      audioFocusStrategy:
          AudioFocusStrategy.request(resumeAfterInterruption: true),
      playInBackground: PlayInBackground.enabled,
    );

    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      _assetsAudioPlayer.builderCurrent(
                        builder: (BuildContext context, Playing playing) {
                          final myAudio = Audio.network(
                            'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
                            //playSpeed: 2.0,
                            metas: Metas(
                              id: "Rock",
                              title: "Rock",
                              artist: "Florent Champigny",
                              album: "RockAlbum",
                              image: MetasImage.network(
                                  "https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png"),
                            ),
                          );
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: 8,
                                surfaceIntensity: 1,
                                shape: NeumorphicShape.concave,
                                boxShape: NeumorphicBoxShape.circle(),
                              ),
                              child:
                                  myAudio.metas.image.type == ImageType.network
                                      ? Image.network(
                                          myAudio.metas.image.path,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.asset(
                                          myAudio.metas.image.path,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.contain,
                                        ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: <Widget>[
                      _assetsAudioPlayer.builderLoopMode(
                        builder: (context, loopMode) {
                          return PlayerBuilder.isPlaying(
                              player: _assetsAudioPlayer,
                              builder: (context, isPlaying) {
                                return PlayingControls(
                                  loopMode: loopMode,
                                  isPlaying: isPlaying,
                                  isPlaylist: true,
                                  onStop: () {
                                    _assetsAudioPlayer.stop();
                                  },
                                  toggleLoop: () {
                                    _assetsAudioPlayer.toggleLoop();
                                  },
                                  onPlay: () {
                                    _assetsAudioPlayer.playOrPause();
                                  },
                                  onNext: () {
                                    //_assetsAudioPlayer.forward(Duration(seconds: 10));
                                    _assetsAudioPlayer.next(keepLoopMode: true
                                        /*keepLoopMode: false*/);
                                  },
                                  onPrevious: () {
                                    _assetsAudioPlayer.previous(
                                        /*keepLoopMode: false*/);
                                  },
                                );
                              });
                        },
                      ),
                      _assetsAudioPlayer.builderRealtimePlayingInfos(
                          builder: (context, infos) {
                        if (infos == null) {
                          return SizedBox();
                        }
                        //print("infos: $infos");
                        return Column(
                          children: [
                            PositionSeekWidget(
                              currentPosition: infos.currentPosition,
                              duration: infos.duration,
                              seekTo: (to) {
                                _assetsAudioPlayer.seek(to);
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
