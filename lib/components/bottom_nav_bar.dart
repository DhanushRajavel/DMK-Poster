import 'package:dmk/constant.dart';
import 'package:dmk/my_flutter_app_icons.dart';
import 'package:dmk/screens/account_screen.dart';
import 'package:dmk/screens/create_screen.dart';
import 'package:dmk/screens/explore_screen.dart';
import 'package:dmk/screens/home_screen.dart';
import 'package:dmk/screens/my_post_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int index;
  const BottomNavBar({super.key, required this.index});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  void onTap(int currentIndex) {
    setState(() {
      index = currentIndex;
    });
    if (currentIndex == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyPostScreen()));
    } else if (currentIndex == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CreateScreen()));
    } else if (currentIndex == 3) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ExploreScreen()));
    } else if (currentIndex == 4) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AccountScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      iconSize: 25,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF0000),
      selectedLabelStyle: kNavBarTextStyle(),
      unselectedLabelStyle: kNavBarTextStyle(),
      unselectedItemColor: Colors.black,
      unselectedIconTheme: const IconThemeData(color: Color(0xFF999999)),
      selectedIconTheme: const IconThemeData(color: Color(0xFFFF0000)),
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            MyFlutterApp.home,
            size: 20,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            MyFlutterApp.my_post,
            size: 20,
          ),
          label: 'My Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            MyFlutterApp.create,
            size: 20,
          ),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            MyFlutterApp.explore,
            size: 20,
          ),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            MyFlutterApp.account,
            size: 20,
          ),
          label: 'Account',
        ),
      ],
    );
  }
}
