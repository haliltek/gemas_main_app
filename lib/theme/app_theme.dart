import 'package:flutter/material.dart';
import '../constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(seedColor: Constants.gemasPrimaryBgColor);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.primary,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(color: colorScheme.onPrimary),
        ),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}
