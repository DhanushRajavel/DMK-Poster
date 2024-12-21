import 'package:dmk/components/call_to_action.dart';
import 'package:dmk/components/reusable_button.dart';
import 'package:dmk/screens/login_screen.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:dmk/constant.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool passwordVisible = false;
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, dynamic>? _getCateroriesData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  Future<void> _loadBasicDetails() async {
    try {
      final basicDetailResponse =
          await ApiService.commonGetDataMethod(endPoint: 'p1-basic-details');
      if (basicDetailResponse != null) {
        setState(() {
          _getCateroriesData = basicDetailResponse['response'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception caught during _loadBasicDetails: $e');
    }
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
                    'Create Account',
                    style: kTitleStyle(),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  _buildFormFeild(),
                  const SizedBox(
                    height: 16,
                  ),
                  ReusableButton(
                    onPressed: () {},
                    title: 'Register',
                    color: const Color(0xFFFF0000),
                  )
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
            ),
            CallToAction(
                docs: 'Already have an account',
                buttonTitle: 'Login',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                })
          ],
        ),
      ),
    );
  }

  Widget _buildFormFeild() {
    return Column(
      children: [
        _buildTextFeild(
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            labelText: 'Full Name'),
        const SizedBox(
          height: 16,
        ),
        //Dropdown
        _buildTextFeild(
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            labelText: 'Phone Number'),
        const SizedBox(
          height: 16,
        ),
        _buildTextFeild(
            controller: passwordController,
            labelText: 'Password',
            obscureText: !passwordVisible,
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
                icon: Icon(passwordVisible
                    ? Icons.visibility
                    : Icons.visibility_off))),
        const SizedBox(
          height: 16,
        ),
        _buildTextFeild(
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            labelText: 'Referral No'),
      ],
    );
  }

  Widget _buildTextFeild(
      {required TextEditingController controller,
      required String labelText,
      Widget? suffixIcon,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: kTextFeildStyle.copyWith(
          labelText: labelText, suffixIcon: suffixIcon),
    );
  }
  // Widget _buildDropDown(){
  //   return DropdownButton(items: items, onChanged: onChanged)
  // }
}
