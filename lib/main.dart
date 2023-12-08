import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sou/values/strings.dart';
import 'package:video_player/video_player.dart';
import 'controller/ZeroKnowledgeProof.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => SettingScreen(),
    ),
  ],
);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Strings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    int secretNumber = 18; // Alice's secret
    ZeroKnowledgeProof zkp = ZeroKnowledgeProof(secretNumber);

    // Alice's part
    BigInt commitment = zkp.generateCommitment();

    // Generate challenge using the transcript
    BigInt challenge = zkp.generateChallenge();

    // Alice's part: Generates a proof based on the challenge
    BigInt proof = zkp.generateProof(challenge);

    // Bob's part: Verifies the proof
    bool isValid = zkp.verify(proof, challenge);
    print(isValid ? "Proof is valid" : "Proof is invalid");
    return Scaffold(
      appBar: MyAppBar(Strings.storeName),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      Row(
      children: [
      Expanded(
      child: InputColumn(),
    ),
    Expanded(
    child: ImageColumn(),
    ),
    ],
    ),

        ],
      ),
    );
  }
}


class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('SettingPage'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text('설정화면'),
          ),
          ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('돌아가기'))
        ],
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String _title;
  MyAppBar(this._title);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_title),
      backgroundColor: Colors.amber,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}
class TwoColumnLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputColumn(),
        ),
        Expanded(
          child: ImageColumn(),
        ),
      ],
    );
  }
}

class InputColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      Padding(padding: EdgeInsets.all(16),child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Last Name'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Age'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Medical Record Number'),
          ),
          SizedBox(height: 16,),
          Text(
           'No details will be shared with the store.',
          ),
          SizedBox(height: 16,),
          Container(

            width: double.infinity, // Make the button full width
            child:           ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).primaryColor, // Set the background color to primary color
    ),
                onPressed: () {
                  context.push('/setting');
                },
                child: Text(

                    Strings.submit,
                  style: TextStyle(
                    color: Theme.of(context).canvasColor, // Set the text color to primary container color
                  ),))
          ),
        ],
      ));

  }
}
class ImageColumn extends StatefulWidget {
  @override
  _ImageColumnState createState() => _ImageColumnState();
}

class _ImageColumnState extends State<ImageColumn> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://github.com/connectamey/shadows-of-the-unseen-store/raw/main/assets/sotu-trailer.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }
  @override
  Widget build(BuildContext context) {
    return
      Padding(padding: EdgeInsets.all(16),child:      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : Container(),
          ),IconButton(
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          )

        ],
      ));

  }
}
