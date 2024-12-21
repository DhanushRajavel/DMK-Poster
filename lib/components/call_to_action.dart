import 'package:dmk/constant.dart';
import 'package:flutter/material.dart';

class CallToAction extends StatelessWidget {
  const CallToAction(
      {super.key,
      required this.docs,
      required this.buttonTitle,
      required this.onPressed});
  final String docs;
  final String buttonTitle;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          docs,
          style: kSubTitleStyle(),
        ),
        TextButton(
            onPressed: onPressed,
            child: Text(
              buttonTitle,
              style: kTextButtonTextStyle(),
            ))
      ],
    );
  }
}
