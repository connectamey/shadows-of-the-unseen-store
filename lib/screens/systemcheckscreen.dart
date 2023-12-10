import 'package:flutter/material.dart';
import 'package:sou/values/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:platform_info/platform_info.dart';
import 'package:get_ip_address/get_ip_address.dart';

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
    _controller = VideoPlayerController.network(
        'https://github.com/connectamey/shadows-of-the-unseen-store/raw/main/assets/sotu-trailer.mp4')
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
    try {
      var ipAddress = IpAddress(type: RequestType.json);

      dynamic data = await ipAddress.getIpAddress();
      print("ip address " + data.toString());
    } on IpAddressException catch (exception) {
      print(exception.message);
    }
    await Future.delayed(Duration(seconds: 3));
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
                        // Download action
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
