import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final double height;
  final double width;
  final String text;

  const RoundedButton({
    super.key,
    required this.height,
    required this.width,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
          color: Color.fromRGBO(91, 91, 91, 1),
          borderRadius: BorderRadius.all(Radius.elliptical(20, 20))),
      child: Center(
          widthFactor: null,
          heightFactor: null,
          child: Text(
              text,
              style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1))
          )
      ),
    );
  }

}