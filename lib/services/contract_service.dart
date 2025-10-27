import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' show Client;
import 'package:web3dart/web3dart.dart';
import '../connect_wallet.dart';

class ContractService {
  /// RPC endpoint
  final String rpcUrl;

  /// Contract address (hex string with 0x prefix).
  final String contractAddress;

  /// Path to ABI file inside assets.
  final String abiAssetPath;

  // Endpoint for the local server to send event data to.
  // Note: For Android Emulator to access the host machine's 'localhost',
  // use 'http://10.0.2.2'.
  static const String _kLocalServerEndpoint =
      'http://10.0.2.2:3000/event'; // TODO: REPLACE with your server address
  // Endpoint for asking the server to store model data to IPFS and return a CID
  static const String _kIPFSEndpoint = 'http://10.0.2.2:3000/ipfs';

  late final Web3Client _web3client;
  DeployedContract? _contract;
  final Map<String, StreamSubscription<dynamic>> _eventSubscriptions = {};

  ContractService({
    this.rpcUrl = 'http://127.0.0.1:7545', // TODO: update rpcURL 
    required this.contractAddress,
    this.abiAssetPath = 'assets/abi/FederatedLearning.json',
  });

  /// Initialize the web3 client and load the contract ABI from assets.
  Future<void> init() async {
    _web3client = Web3Client(rpcUrl, Client());

    final abiJson = await rootBundle.loadString(abiAssetPath);
    final abi = ContractAbi.fromJson(abiJson, 'FederatedLearning');
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

  /// Start listening to contract events, in particular `ModelSubmitted`.
  /// When a ModelSubmitted event arrives we decode it, post the model data
  /// to the IPFS endpoint, then notify the server with the returned CID.
  void startEventListening() {
    final contract = _contract;
    if (contract == null) {
      throw StateError('ContractService not initialized. Call init() first.');
    }

    // Define events we care about and corresponding handler functions.
    final Map<String, Future<void> Function(Map<String, dynamic>)> handlers = {
      'ModelSubmitted': handleModelSubmitted, // client send trained data to server
      'ModelValidated': handleModelValidated, // client validate model, send feedback
      'NewRoundStarted': handleNewRoundStarted, // new round begins, client receive initial global model
      'RoundFinalized': handleRoundFinalized, // receive global model finalized
      'GlobalModelChanged': handleGlobalModelChanged, // receive global model changed
    };

    for (final entry in handlers.entries) { //handle entries, i dont understand
      final eventName = entry.key;
      // If already subscribed, skip
      if (_eventSubscriptions.containsKey(eventName)) continue;

      try {
        final contractEvent = contract.event(eventName); // get event from contract
        final filter = FilterOptions.events(
          contract: contract,
          event: contractEvent,
        );
        final sub = _web3client.events(filter).listen((evt) async {
          try {
            final decoded = contractEvent.decodeResults(evt.topics!, evt.data!);
            final payload = <String, dynamic>{
              'values': decoded.map((v) => v.toString()).toList(),
              'data': evt.data,
              'topics': evt.topics,
            };
            await entry.value(payload);
          } catch (e, st) {
            print('Error handling $eventName event: $e\n$st');
          }
        });
        _eventSubscriptions[eventName] = sub;
      } catch (e) {
        // If the contract doesn't define the event or decoding fails, continue.
        print('Could not subscribe to event $eventName: $e');
      }
    }
  }

  /// Empty handlers for model/round related events. Fill in business logic as needed.
  Future<void> handleModelSubmitted(Map<String, dynamic> payload) async {
    // TODO: implement processing of model submission events.
    // DEMO: 
    /// 1. Train AI model on local data
    /// 2. Post trained model to IPFS via server endpoint, get CID
    /// 3. Send CID to server so it can continue the protocol
    /// 
    print('Received ModelSubmitted event payload: $payload');

    // Post the submission to IPFS (server handles actual IPFS interaction)
    final cid = await _postModelToIPFS(payload);
    if (cid == null) {
      print('Failed to obtain CID for model submission');
      return;
    }

    // Notify the server that we have pinned/stored the model and provide the CID.
    await _postEventToServer('ModelSubmissionCID', {
      'cid': cid,
      'originalSubmission': payload,
      'receivedAt': DateTime.now().toIso8601String(),
    });
    print('handleModelSubmitted called with payload: $payload');
  }

  Future<void> handleModelValidated(Map<String, dynamic> payload) async {
    // TODO: implement processing when a model is validated.
    /// 1. Recieve global model from server
    /// 2. Validate model on local validation data
    /// 3. Send validation results back to server
    /// 
    print('handleModelValidated called with payload: $payload');
  }

  Future<void> handleNewRoundStarted(Map<String, dynamic> payload) async {
    // TODO: implement processing when a new round starts.
    print('handleNewRoundStarted called with payload: $payload');
  }

  Future<void> handleRoundFinalized(Map<String, dynamic> payload) async {
    // TODO: implement processing when a round is finalized.
    print('handleRoundFinalized called with payload: $payload');
  }

  Future<void> handleGlobalModelChanged(Map<String, dynamic> payload) async {
    // TODO: implement processing when the global model changes.
    print('handleGlobalModelChanged called with payload: $payload');
    // Example: if the payload contains a CID, fetch the model from IPFS
    // and do further processing.
    final cid = payload['cid'] as String? ??
        (payload['values'] is List && payload['values'].isNotEmpty ? payload['values'][0] : null);
    if (cid != null) {
      final model = await getModelFromIPFS(cid.toString());
      if (model != null) {
        print('Fetched global model for CID $cid: keys=${model.keys.toList()}');
        // TODO: apply model (e.g., update local model weights)
      } else {
        print('Failed to fetch global model for CID $cid');
      }
    }
  }

  /// Stop listening and clear subscriptions.
  Future<void> stopEventListening() async {
    for (final sub in _eventSubscriptions.values) {
      await sub.cancel();
    }
    _eventSubscriptions.clear();
  }

  /// Handle a model submission payload from the contract event.
  /// Steps:
  ///  1. Post model data to IPFS via the server endpoint and get a CID.
  ///  2. Notify the server (or contract owner endpoint) with the CID so the
  ///     server can continue the protocol.
  Future<void> actOnModelSubmission(Map<String, dynamic> submission) async {
    // You can add validation / transformation here as needed.
    print('Received ModelSubmitted event payload: $submission');

    // Post the submission to IPFS (server handles actual IPFS interaction)
    final cid = await _postModelToIPFS(submission);
    if (cid == null) {
      print('Failed to obtain CID for model submission');
      return;
    }

    // Notify the server that we have pinned/stored the model and provide the CID.
    await _postEventToServer('ModelSubmissionCID', {
      'cid': cid,
      'originalSubmission': submission,
      'receivedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Posts model data to the configured IPFS endpoint on the local server and
  /// returns the CID string on success, otherwise null.
  Future<String?> _postModelToIPFS(Map<String, dynamic> data) async {
    final client = Client();
    try {
      final response = await client.post(
        Uri.parse(_kIPFSEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return body['cid'] as String?;
      }
      print('IPFS post failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error posting to IPFS endpoint: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Fetches model data from the IPFS server by CID. Returns parsed JSON
  /// (Map) if the server returns JSON, otherwise returns null.
  Future<Map<String, dynamic>?> getModelFromIPFS(String cid) async {
    final client = Client();
    try {
      // Construct URL: assume server exposes GET /ipfs/{cid}
      final uri = Uri.parse(_kIPFSEndpoint.endsWith('/')
          ? '${_kIPFSEndpoint}$cid'
          : '${_kIPFSEndpoint}/$cid');
      final resp = await client.get(uri, headers: {'Accept': 'application/json'});
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body is Map<String, dynamic>) return body;
        // If server returns non-map (e.g., raw bytes/base64), wrap it
        return {'data': body};
      }
      print('Failed to fetch CID $cid: ${resp.statusCode} ${resp.body}');
      return null;
    } catch (e) {
      print('Error fetching CID $cid from IPFS endpoint: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // ADDED: Method to post event data to the server
  /// Posts event data to a local server endpoint.
  Future<void> _postEventToServer(
    String eventName,
    Map<String, dynamic> data,
  ) async {
    // Using a new client instance for this specific HTTP call
    final client = Client();
    try {
      final response = await client.post(
        Uri.parse(_kLocalServerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'eventName': eventName,
          'eventData': data,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully posted $eventName event to server.');
      } else {
        print(
          'Failed to post $eventName event. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error posting event to server: $e');
    } finally {
      client.close();
    }
  }

  // (Other event subscription helpers were removed; use startEventListening() above)

  /// Returns the currently connected wallet address string (or null).
  String? getConnectedWalletAddress() => getCurrentWalletAddress();

  /// Dispose underlying resources.
  void dispose() {
    try {
      // Stop listening before disposing the client.
      stopEventListening();
    } catch (_) {}
    try {
      _web3client.dispose();
    } catch (_) {}
  }
}
