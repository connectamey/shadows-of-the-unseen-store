import 'package:flutter/material.dart';
import 'package:sou/values/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:platform_info/platform_info.dart';
import 'package:get_ip_address/get_ip_address.dart';

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:js/js.dart'
    if (dart.library.io) 'package:dart_web3_core/lib/src/browser/js-stub.dart'
    if (dart.library.js) 'package:js/js.dart';
import 'package:dart_web3_core/browser.dart'
    if (dart.library.io) 'package:dart_web3_core/lib/src/browser/dart_wrappers_stub.dart'
    if (dart.library.js) 'package:dart_web3_core/browser.dart';
import 'package:dart_web3_core/dart_web3_core.dart';

var credentials;
late final neweth;

@JS()
@anonymous
class JSrawRequestParams {
  external String get chainId;

  external factory JSrawRequestParams({String chainId});
}

Future<void> main() async {}

class SystemCheckScreen extends StatefulWidget {
  @override
  _SystemCheckScreenState createState() => _SystemCheckScreenState();
}

class _SystemCheckScreenState extends State<SystemCheckScreen> {
  late VideoPlayerController _controller;
  bool? systemCheckResult; // null: not checked, true: passed, false: failed
  bool isVideoEnded = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network('assets/sotu-trailer.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
    _controller.addListener(() {
      if (!_controller.value.isPlaying &&
          _controller.value.position == _controller.value.duration) {
        setState(() {
          isVideoEnded = true;
        });
      }
    });
    performSystemCheck();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void performSystemCheck() async {
    final eth = window.ethereum;
    if (eth == null) {
      neweth = eth;
      print('MetaMask is not available');
      return;
    }

    final client = Web3Client.custom(eth.asRpcService());
    credentials = await eth.requestAccount();
    // you can also use eth.requestAllAccounts() to have an array of all authorized Metamask accounts.
    print('Using ${credentials.address}');
    print('Client is listening: ${await client.isListeningForNetwork()}');
    //
    // final message = Uint8List.fromList(utf8.encode('Hello from webthree'));
    // final signature = await credentials.signPersonalMessage(message);
    // print('Signature: ${base64.encode(signature)}');
    //
    // await eth.rawRequest('wallet_switchEthereumChain',
    //     params: [JSrawRequestParams(chainId: '0x507')]);
    // final String chainIDHex = await eth.rawRequest('eth_chainId') as String;
    // final chainID = int.parse(chainIDHex);
    // print('chainID: $chainID');

    try {
      var ipAddress = IpAddress(type: RequestType.json);

      dynamic data = await ipAddress.getIpAddress();
      print("ip address " + data.toString());
    } on IpAddressException catch (exception) {
      systemCheckResult = false;
      print(exception.message);
    }
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      if (Platform.I.operatingSystem == OperatingSystem.windows &&
          platform.numberOfProcessors >= 4 &&
          Platform.instance.version.contains("10")) {
        systemCheckResult = true;
      } else {
        systemCheckResult = false;
      }
      // systemCheckResult = true;
    });
  }

  void sendTransactionToEth() async {
    final eth = window.ethereum;
    if (eth == null) {
      neweth = eth;
      print('MetaMask is not available');
      return;
    }

    final client = Web3Client.custom(eth.asRpcService());
    credentials = await eth.requestAccount();
    // you can also use eth.requestAllAccounts() to have an array of all authorized Metamask accounts.
    print('Using ${credentials.address}');
    print('Client is listening: ${await client.isListeningForNetwork()}');

    final message = Uint8List.fromList(utf8.encode(Strings.zkpProof));
    final signature = await credentials.signPersonalMessage(message);
    print('Signature: ${base64.encode(signature)}');

    await eth.rawRequest('wallet_switchEthereumChain',
        params: [JSrawRequestParams(chainId: '0xAA36A7')]);
    final String chainIDHex = await eth.rawRequest('eth_chainId') as String;
    final chainID = int.parse(chainIDHex);
    print('chainID: $chainID');

    await client.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(
            '0x0A06e580452216d57b60f0Bd4CA4AE81fc76C5E0'),
        gasPrice: EtherAmount.inWei(BigInt.from(6640520)),
        maxGas: 100000,
        value: EtherAmount.fromDouble(EtherUnit.ether, 0.0001),
        data: Uint8List.fromList(utf8.encode(Strings.zkpProof)),
      ),
    );

    window.location.href =
        'https://drive.google.com/drive/folders/13L4hL3hbEQHp7oxKdPYZIFop-0tfjgYI';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/sotu-logo-horizontal.png', width: 320),
              SizedBox(height: 16),
              if (_controller.value.isInitialized)
                Container(
                  width: 1270 / MediaQuery.of(context).devicePixelRatio,
                  height: 720 / MediaQuery.of(context).devicePixelRatio,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: VideoPlayer(_controller),
                  ),
                ),

              SizedBox(height: 16),

              // Replay Button

              // Play Toggle Button and System Check Result
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (isVideoEnded)
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _controller.seekTo(Duration.zero);
                          _controller.play();
                          isVideoEnded = false;
                        });
                      },
                      child: Icon(Icons.replay),
                    ),
                  if (!isVideoEnded)
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),

                  SizedBox(width: 12),
                  if (systemCheckResult == null) CircularProgressIndicator(),
                  SizedBox(width: 12),
                  if (systemCheckResult == null) Text(Strings.systemCheckNote),
                  // SizedBox(width: 16),

                  if (systemCheckResult == true)
                    Text(Strings.systemCheckSuccessNote),
                  SizedBox(width: 16),
                  if (systemCheckResult == true)
                    ElevatedButton(
                      onPressed: () {
                        sendTransactionToEth();
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).secondaryHeaderColor,
                          backgroundColor: Theme.of(context)
                              .primaryColor, // Foreground color (text color)
                          padding: EdgeInsets.all(16)),
                      child: Text(Strings.downloadNow),
                    ),
                  if (systemCheckResult == false)
                    Text(Strings.systemCheckFailureNote,
                        style: TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
