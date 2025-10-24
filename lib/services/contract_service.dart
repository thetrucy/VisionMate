import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' show Client;
import 'package:web3dart/web3dart.dart';
import '../connect_wallet.dart';

/// A small, focused service to load a contract ABI from assets and call
/// read-only contract functions using `web3dart`.
///
/// Usage:
/// final svc = ContractService(
///   contractAddress: '0x...your address...',
/// );
/// await svc.init();
/// final value = await svc.callRead('getValue', []);
class ContractService {
  /// RPC endpoint, defaulting to local Ganache.
  final String rpcUrl;

  /// Contract address (hex string with 0x prefix).
  final String contractAddress;

  /// Path to ABI file inside assets.
  final String abiAssetPath;

  late final Web3Client _web3client;
  DeployedContract? _contract;

  ContractService({
    this.rpcUrl = 'http://127.0.0.1:7545',
    required this.contractAddress,
    this.abiAssetPath = 'assets/abi/con_1.json',
  });

  /// Initialize the web3 client and load the contract ABI from assets.
  Future<void> init() async {
    _web3client = Web3Client(rpcUrl, Client());

    final abiJson = await rootBundle.loadString(abiAssetPath);
    final abi = ContractAbi.fromJson(abiJson, 'Con1');
    final address = EthereumAddress.fromHex(contractAddress);
    _contract = DeployedContract(abi, address);
  }

  /// Call a view/pure function from the loaded contract.
  /// Throws if the contract wasn't initialized.
  Future<List<dynamic>> callRead(String name, List<dynamic> params) async {
    final contract = _contract;
    if (contract == null) {
      throw StateError('ContractService not initialized. Call init() first.');
    }
    final function = contract.function(name);
    return await _web3client.call(
      contract: contract,
      function: function,
      params: params,
    );
  }

  /// Returns the currently connected wallet address string (or null).
  String? getConnectedWalletAddress() => getCurrentWalletAddress();

  /// Dispose underlying resources.
  void dispose() {
    try {
      _web3client.dispose();
    } catch (_) {}
  }
}
