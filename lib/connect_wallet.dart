import 'package:flutter/material.dart';
import './function.dart';
import "package:reown_appkit/reown_appkit.dart";

// // AppKit Modal instance
// final _appKitModal = ReownAppKitModal(
//   context: BuildContext(), // required BuildContext
//   projectId: '{YOUR_PROJECT_ID}',
//   metadata: const PairingMetadata(
//     name: 'Vision Mate App',
//     description: 'App for connecting wallet and IoT device',
//     url: 'https://github.com/thetrucy/vweb.github.io',
//     icons: ['https://github.com/thetrucy/vweb.github.io/blob/main/vicon.png'],
//     redirect: Redirect(
//       native: 'https://github.com/thetrucy/vweb.github.io',
//       universal: 'https://github.com/thetrucy/vweb.github.io',
//       linkMode: true|false,
//     ),
//   ),
//   enableAnalytics: true,
//   siweConfig: SIWEConfig(...),
//   featuresConfig: FeaturesConfig(...),
//   getBalanceFallback: () async {},
//   disconnectOnDispose: true|false,
//   customWallets: [
//     ReownAppKitModalWalletInfo(
//       listing: AppKitModalWalletListing(
//         ...
//       ),
//     ),
//   ],
// );

// // Register here the event callbacks on the service you'd like to use. See `Events` section.

// await _appKitModal.init();

class ConnectWalletPage extends StatefulWidget {
  const ConnectWalletPage({super.key, required this.title});

  final String title;

  @override
  State<ConnectWalletPage> createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends State<ConnectWalletPage> {
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
