import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Old Colors
  static const Color backgroundColor = Color(0xFF0F1A2E);
  static const Color secondaryBlue = Color(0xFF294073);
  static const Color accentBlue = Color(0xFF879ED4);
  static const Color buttonColor = Color(0xFF7592B0);
  static const Color white = Colors.white;

  // New Colors
  static const Color primaryBackground = Color(0xFF000000);
  static const Color secondaryBackground = Color(0xFF191919);
  static const Color primaryBlue = Color(0xFF278EB5);
  static const Color primaryPurple = Color(0xFF7328B5);
  static const Color border = Color(0xFF414141);
  static const Color text = Color(0xFFFDFDFD);
  static const Color secondaryText = Color(0x4DFDFDFD);

  static TextStyle get spaceGroteskBold => GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
        color: text,
      );

  static TextStyle get sourceSansPro => GoogleFonts.sourceSansPro(
        fontWeight: FontWeight.w400,
        color: text,
      );

  static TextStyle get sourceSansProBold => GoogleFonts.sourceSansPro(
        fontWeight: FontWeight.w700,
        color: text,
      );

  static TextStyle montserrat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color = text,
    double? lineHeight
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
    );
  }
}
