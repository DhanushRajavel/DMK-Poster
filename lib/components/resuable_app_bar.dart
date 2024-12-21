import 'package:dmk/components/reusable_button.dart';
import 'package:flutter/material.dart';

class ResuableAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ResuableAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'data',
        style: null,
      ),
      actions: [
        ReusableButton(
          onPressed: () {},
          title: 'Request Desing',
          color: const Color(0xFFFF0000),
        )
      ],
      scrolledUnderElevation: 0.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
