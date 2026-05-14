import 'package:flutter/material.dart';

Widget slideRightBackground(IconData icon, String text, BuildContext context,
    {Color? color, Color? secondColor}) {
  return Container(
    color: color ?? Theme.of(context).colorScheme.primary,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            icon,
            color: secondColor ?? Theme.of(context).colorScheme.inversePrimary,
          ),
          Text(
            " $text",
            style: TextStyle(
              color:
                  secondColor ?? Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    ),
  );
}

Widget slideLeftBackground(IconData icon, String text, BuildContext context,
    {Color? color, Color? secondColor}) {
  return Container(
    color: color ?? Theme.of(context).colorScheme.primary,
    child: Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            icon,
            color: secondColor ?? Theme.of(context).colorScheme.inversePrimary,
          ),
          Text(
            " $text",
            style: TextStyle(
              color:
                  secondColor ?? Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    ),
  );
}
