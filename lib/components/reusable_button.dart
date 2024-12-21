import 'package:dmk/constant.dart';
import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  ReusableButton(
      {super.key, required this.onPressed, required this.title,required this.color});
  final Function()? onPressed;
  final String title;
  Color color;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            title,
            style: kButtonTextStyle(),
          ),
        ));
  }
}
