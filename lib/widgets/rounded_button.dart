import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final void Function() onPressed;

  const RoundedButton({
    super.key,
    required this.height,
    required this.width,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        backgroundColor: const Color.fromRGBO(91, 91, 91, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        )
      ),
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