import 'package:flutter/material.dart';

class MyFunctionPage extends StatelessWidget {
  const MyFunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Function Page'),
      ),
      body: const Center(
        child: Text('This is the Function Page'),
      ),
    );
  }
}