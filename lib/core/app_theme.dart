import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        indicatorColor: kGreyColor,
        primaryColorLight: kWhiteColor,
        primaryColorDark: kBlackColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kBlackColor),
        primaryIconTheme: const IconThemeData().copyWith(color: kBlackColor),
        scaffoldBackgroundColor: kWhiteColor,
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: 25,
                color: kBlackColor,
              ),
              bodySmall: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                color: kBlackColor,
              ),
            ),
        appBarTheme: const AppBarTheme(
            backgroundColor: kWhiteColor, foregroundColor: kBlackColor),
        fontFamily: GoogleFonts.montserrat().fontFamily,
        iconTheme: const IconThemeData().copyWith(color: kGreyColor),
      );

  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      primaryColorLight: kWhiteColor,
      primaryColorDark: kBlackColor,
      indicatorColor: kWhiteColor.withOpacity(0.5),
      primaryIconTheme: const IconThemeData().copyWith(color: kWhiteColor),
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: kDarkColor,
      dividerTheme: const DividerThemeData().copyWith(color: kGreyOpacityColor),
      textTheme: ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(
              fontSize: 25,
              color: kWhiteColor,
            ),
            bodySmall: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15,
              color: kWhiteColor,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: kBlackColor,
        foregroundColor: kWhiteColor,
        iconTheme: const IconThemeData().copyWith(color: kWhiteColor),
        actionsIconTheme: const IconThemeData().copyWith(color: kWhiteColor),
      ),
      fontFamily: GoogleFonts.montserrat().fontFamily,
      iconTheme:
          const IconThemeData().copyWith(color: kWhiteColor.withOpacity(0.7)),
      inputDecorationTheme: const InputDecorationTheme().copyWith(
        iconColor: kWhiteColor,
        prefixIconColor: kWhiteColor,
        suffixIconColor: kWhiteColor,
      ));
}
