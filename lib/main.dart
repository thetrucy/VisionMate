import 'package:flutter/material.dart';
import './function.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _connectedAddress;
  final walletController = TextEditingController();
  
  @override
  void dispose() {
    // Dispose the controller to avoid memory leaks
    walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextFormField(
                controller: walletController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your wallet address',
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                backgroundColor: Colors.white38,
                shadowColor: Colors.blueGrey
              ),
              onPressed: _connectWallet,
              child: const Text('Connect Wallet'),
            ),
            const SizedBox(height: 12),
            if (_connectedAddress != null) ...[
              const Text('Connected address:'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SelectableText(
                  _connectedAddress!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToFunctionPage,
        tooltip: 'Next page',
        child: const Icon(Icons.arrow_right),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _connectWallet() {
    final input = walletController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a wallet address')),
      );
      return;
    }

    // Basic validation: common ethereum address pattern (starts with 0x and length 42)
    final isProbablyEthAddress = input.startsWith('0x') && input.length == 42;
    if (!isProbablyEthAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warning: address format looks unusual')),
      );
    }

    setState(() {
      _connectedAddress = input;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connected: ${_connectedAddress!}')),
    );
  }
  void _navigateToFunctionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyFunctionPage()),
    );
  }
}
