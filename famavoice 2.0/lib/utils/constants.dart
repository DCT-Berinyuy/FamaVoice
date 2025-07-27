
import 'package:flutter/material.dart';

// Colors
const kPrimaryColor = Colors.green;
const kSecondaryColor = Colors.blue;

// Theme
final kThemeData = ThemeData(
  primaryColor: kPrimaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: kSecondaryColor),
);

final kDarkThemeData = ThemeData.dark().copyWith(
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(
    secondary: kSecondaryColor,
    brightness: Brightness.dark,
    onPrimary: Colors.white, // Text/icons on primary color
    onSurface: Colors.white, // Text/icons on surface color
  ),
);
