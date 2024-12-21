import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle kAppNameTitleStyle() {
  return GoogleFonts.solway(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle kTitleStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle kSubTitleStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black));
}

TextStyle kTextButtonStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue));
}

const kTextFeildStyle = InputDecoration(
  labelText: "LabelText",
  labelStyle: TextStyle(fontSize: 14, color: Color(0xFF8B8B8B)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Color(0xFFFF0000), width: 2)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Color(0xFFFF0000), width: 2)),
);

TextStyle kTextButtonTextStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFF0000)));
}

TextStyle kButtonTextStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)));
}

TextStyle kPosterTitleTextStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(fontSize: 13, color: Colors.black));
}

TextStyle kNavBarTextStyle() {
  return GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 12));
}

TextStyle kTodayPosterLabelStyle() {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w500, fontSize: 10));
}
