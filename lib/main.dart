import 'package:flutter/material.dart';
import './connect_wallet.dart';

void main() {
  runApp(const MyApp());
}

const Color kBackgroundColor = Color.fromARGB(255, 254, 254, 254); // White background
const Color kPrimaryColor = Color.fromARGB(255, 47, 4, 115); // Dark purple
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
          primary: kPrimaryColor,
          surface: kBackgroundColor,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: kPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      home: const ConnectWalletPage(title: 'Vision Mate'),
    );
  }
}

// Main app navigation is now handled directly through ConnectWalletPage
