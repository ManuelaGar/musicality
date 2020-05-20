import 'package:flutter/material.dart';

class PlayPauseIconButton extends StatelessWidget {
  PlayPauseIconButton(
      {@required this.onTap,
      @required this.icon,
      @required this.containerSize});

  final Function onTap;
  final IconData icon;
  final double containerSize;

  @override
  Widget build(BuildContext context) {
    double iconSize = containerSize - 20.0;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: const Alignment(0, 0),
        children: <Widget>[
          Container(
            height: containerSize,
            width: containerSize,
            margin: EdgeInsets.fromLTRB(5, 3, 5, 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1D1E33).withOpacity(0.3),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
