import 'package:flutter/material.dart';

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
