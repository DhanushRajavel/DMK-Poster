import 'package:dmk/constant.dart';
import 'package:flutter/material.dart';
import 'reusable_button.dart';

class ReusableAlertBox extends StatelessWidget {
  final String title;
  final String content;
  final Function()? onPressed;

  const ReusableAlertBox({
    super.key,
    required this.title,
    required this.content,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          titleTextStyle: kTitleStyle(),
          scrollable: true,
          content: Text(content),
          actions: <Widget>[
            ReusableButton(
              onPressed: onPressed ?? () => Navigator.pop(context),
              title: 'Okay',
              
                    color: const Color(0xFFFF0000),
            ),
          ],
        );
      },
    );
  }
}
