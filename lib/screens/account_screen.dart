// ignore_for_file: prefer_const_constructors

import 'package:dmk/components/bottom_nav_bar.dart';
import 'package:dmk/constant.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<String> accountFieldName = [
    'Subscription',
    'My Frame',
    'Downloads',
    'Request List',
    'Rate us',
    'Share App',
    'Delete Account'
  ];
  List<IconData> accountFieldIcons = [Icons.credit_card];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Account',
          style: kSubTitleStyle(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: ListView.builder(
          itemCount: accountFieldName.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _buildAccountFieldsCard(
                  accountFieldName[index],
                  () {
                    print('${accountFieldName[index]} tapped');
                  },
                ),
                SizedBox(height: 5),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(index: 4),
    );
  }

  Widget _buildAccountFieldsCard(String title, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.red, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: 10,
              color: Colors.red,
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  title,
                  style: kSubTitleStyle(),
                ),
                trailing: Icon(Icons.movie),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
