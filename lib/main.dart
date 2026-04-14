// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'auth_gate.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProvider, _) {
          // On récupère le ColorScheme en fonction du mode
          final colorScheme = themeProvider.isDark
              ? const ColorScheme.dark(
            primary: Color(0xFF1DE9B6),
            secondary: Color(0xFF0D47A1),
            background: Color(0xFF121212),
            surface: Color(0xFF1E1E1E),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onBackground: Colors.white,
            onSurface: Colors.white,
            error: Colors.redAccent,
          )
              : const ColorScheme.light(
            primary: Color(0xFF0D47A1),
            secondary: Color(0xFF1DE9B6),
            background: Color(0xFFF5F5F5),
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Color(0xFF212121),
            onSurface: Color(0xFF212121),
            error: Colors.redAccent,
          );

          return MaterialApp(
            title: 'SmartRoute',
            themeMode: themeProvider.mode,
            theme: ThemeData(
              fontFamily: 'Ubuntu',
              colorScheme: colorScheme,
              scaffoldBackgroundColor: colorScheme.background,
              appBarTheme: AppBarTheme(
                backgroundColor: colorScheme.surface,
                iconTheme: IconThemeData(color: colorScheme.onSurface),
                titleTextStyle: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                elevation: 1,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
              ),
              textTheme: TextTheme(
                titleLarge: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                bodyMedium: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onBackground,
                ),
                bodySmall: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Ubuntu',
              colorScheme: colorScheme,
              scaffoldBackgroundColor: colorScheme.background,
              appBarTheme: AppBarTheme(
                backgroundColor: colorScheme.surface,
                iconTheme: IconThemeData(color: colorScheme.onSurface),
                titleTextStyle: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                elevation: 1,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
              ),
              textTheme: TextTheme(
                titleLarge: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                bodyMedium: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onBackground,
                ),
                bodySmall: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
            ),
            home: AuthGate(),
          );
        },
      ),
    );
  }
}
