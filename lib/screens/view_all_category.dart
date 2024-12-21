// ignore_for_file: prefer_const_constructors

import 'package:dmk/constant.dart';
import 'package:flutter/material.dart';

class ViewAllCategory extends StatefulWidget {
  const ViewAllCategory({super.key});

  @override
  State<ViewAllCategory> createState() => _ViewAllCategoryState();
}

class _ViewAllCategoryState extends State<ViewAllCategory> {
  int selectedCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Quotes',
          style: kSubTitleStyle(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [_buildCategoriesCard()],
        ),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCardIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: selectedCardIndex == index
                        ? Color(0xFFFF0000)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('images/dmk.jpg'),
                      ),
                    ),
                    Text(
                      'Card $index',
                      style: kSubTitleStyle(),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
