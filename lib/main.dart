import 'package:flutter/material.dart';
import './connect_wallet.dart';

void main() {
  runApp(const MyApp());
}

const Color kBackgroundColor = Color.fromARGB(255, 4, 0, 24); // Dark background
const Color kPrimaryColor = Color(0xFFFFCC00); // Bright accessible yellow
const Color kSuccessColor = Color(0xFF4CAF50); // Green for success

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision Mate',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          surface: Colors.white
        ),
        // colorScheme: const ColorScheme.dark(
        //   primary: kPrimaryColor,
        //   surface: kBackgroundColor,
        //   onSurface: Colors.white,
        // ),
        // scaffoldBackgroundColor: kBackgroundColor,
        // appBarTheme: const AppBarTheme(
        //   backgroundColor: kBackgroundColor,
        //   elevation: 0,
        // ),
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        //   titleLarge: TextStyle(color: kPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold),
        //   bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
        //   bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
        // ),
      ),
      home: const ConnectWalletPage(title: 'Vision Mate'),
    );
  }
}

// Main app navigation is now handled directly through ConnectWalletPage
