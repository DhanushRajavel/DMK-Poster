import 'package:dmk/constant.dart';
import 'package:dmk/screens/home_screen.dart';
import 'package:dmk/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String id = 'splash_screen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> _navigateTextScreen() async{
    await Future.delayed(const Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if(isLoggedIn){
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    }else{
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateTextScreen();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.jpg',width: 220,height: 220,),
            const SizedBox(height: 20,),
            Text('DMK Poster App',style: kAppNameTitleStyle(),)
          ],
        ),
      ),
    );
  }
}