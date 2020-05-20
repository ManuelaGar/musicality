import 'package:flutter/material.dart';

class DurationIndicators extends StatelessWidget {
  const DurationIndicators({
    @required this.position,
    @required this.duration,
    @required this.positionText,
    @required this.durationText,
  });

  final Duration position;
  final Duration duration;
  final positionText;
  final durationText;

  static Color kNumberColor = Colors.white;

  static String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('$days');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('$hours');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('$minutes');
    } else if (tokens.isEmpty) {
      tokens.add('0');
    }
    if (seconds < 10) {
      tokens.add('0$seconds');
    } else {
      tokens.add('$seconds');
    }
    //tokens.add('$seconds');

    return tokens.join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            position != null
                ? "${positionText ?? ''}"
                : duration != null ? durationText : '',
            /*? formatDuration(position) ?? ''
                : duration != null ? formatDuration(duration) : '',*/
            style: TextStyle(fontSize: 15.0, color: kNumberColor),
          ),
          Text(
            position != null
                ? "${durationText ?? ''}"
                : duration != null ? durationText : '',
            /*? formatDuration(duration) ?? ''
                : duration != null ? formatDuration(duration) : '',*/
            style: TextStyle(fontSize: 15.0, color: kNumberColor),
          ),
        ],
      ),
    );
  }
}
