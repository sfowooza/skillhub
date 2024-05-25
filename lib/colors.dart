import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BaseColors {
  Color baseTextColor = Color.fromARGB(255, 39, 17, 38);
  Color UserDataTextColor = Color.fromARGB(255, 182, 55, 233);
  Color kLightGreen=  Color.fromARGB(255, 218, 255, 123);


  final customTheme = ThemeData(
  primarySwatch: MaterialColor(
    0xFF7E57C2,
    {
      50: Color(0xFFEDE7F6),
      100: Color(0xFFD1C4E9),
      200: Color(0xFFB39DDB),
      300: Color(0xFF9575CD),
      400: Color(0xFF7E57C2),
      500: Color(0xFF673AB7),
      600: Color(0xFF5E35B1),
      700: Color(0xFF512DA8),
      800: Color(0xFF4527A0),
      900: Color(0xFF311B92),
    },
  ),
  fontFamily: GoogleFonts.poppins().fontFamily,
  appBarTheme: AppBarTheme(
    titleTextStyle: GoogleFonts.montserrat(),
  ),
  textTheme: TextTheme(
    // ignore: deprecated_member_use
    bodyText1: GoogleFonts.poppins(),
    // ignore: deprecated_member_use
    bodyText2: GoogleFonts.poppins(),
  ),
);
}
