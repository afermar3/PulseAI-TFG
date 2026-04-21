import 'package:flutter/material.dart';

class pant_pruebas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Dot(),
        SizedBox(width: 10),
        Dot(),
        SizedBox(width: 10),
        Dot(),
      ],
    );
  }
}

class Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
