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
            style: TextStyle(fontSize: 15.0, color: kNumberColor),
          ),
          Text(
            position != null
                ? "${durationText ?? ''}"
                : duration != null ? durationText : '',
            style: TextStyle(fontSize: 15.0, color: kNumberColor),
          ),
        ],
      ),
    );
  }
}
