import 'package:dmk/components/call_to_action.dart';
import 'package:dmk/components/reusable_alert_box.dart';
import 'package:dmk/components/reusable_button.dart';
import 'package:dmk/screens/home_screen.dart';
import 'package:dmk/screens/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:dmk/constant.dart';
import 'package:dmk/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  Future<void> _loginUser() async {
    try {
      final phoneNumber = phoneNumberController.text.trim();
      final password = passwordController.text.trim();

      // if (phoneNumber.isEmpty || password.isEmpty) {
      //   const ReusableAlertBox(
      //     title: 'Validation Error',
      //     content: 'Please enter both phone number and password.',
      //   ).show(context);
      //   return;
      // }

      final response = await ApiService.loginUser(
        mobileNo: phoneNumber,
        password: password,
        endPoint: 'p1-user-login',
      );

      if (response['status'] == 0) {
        ReusableAlertBox(
          title: 'Login Failed',
          content: response['message'],
        ).show(context);
      } else {
        final accessToken = response['accesstoken'];
        await saveUserData(response['data'], accessToken);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacementNamed(context, HomeScreen.id);
      }
    } catch (e) {
      print('Exception in Login Page: $e');
      const ReusableAlertBox(
        title: 'Error',
        content: 'An unexpected error occurred. Please try again.',
      ).show(context);
    }
  }

  Future<void> saveUserData(
      Map<String, dynamic> data, String accessToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', data['name'] ?? '');
    await prefs.setString('mobile', data['mobile'] ?? '');
    await prefs.setString('photo', data['photo'] ?? '');
    await prefs.setString('accesstoken', accessToken ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 92),
              child: Column(
                children: [
                  Image.asset(
                    'images/logo.jpg',
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Login',
                    style: kTitleStyle(),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  _buildFormField(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forget Password',
                        style: kTextButtonTextStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ReusableButton(onPressed: _loginUser, title: 'Login' , 
                    color: const Color(0xFFFF0000),)
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
            ),
            CallToAction(
              docs: 'Don\'t have an account',
              buttonTitle: 'Register',
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationPage()));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFormField() {
    return Column(
      children: [
        _buildTextField(
          controller: phoneNumberController,
          keyboardType: TextInputType.number,
          labelText: 'Phone Number',
        ),
        const SizedBox(
          height: 16,
        ),
        _buildTextField(
          controller: passwordController,
          labelText: 'Password',
          obscureText: !passwordVisible,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
            icon: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: kTextFeildStyle.copyWith(
        labelText: labelText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
