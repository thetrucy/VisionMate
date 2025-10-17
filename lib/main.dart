import 'package:flutter/material.dart';
import './connect_wallet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Mate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ConnectWalletPage(title: 'Vision Mate'),
    );
  }
}

// Main app navigation is now handled directly through ConnectWalletPage
