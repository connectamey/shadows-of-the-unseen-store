import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_info/platform_info.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';


import '../controller/ZeroKnowledgeProof.dart';
import '../main.dart';
import '../values/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    print("version "+Platform.instance.version);
    print("operatingSystem ");
    print(Platform.I.operatingSystem);
    print("processors ");
    print(platform.numberOfProcessors);
    print("processors ");
    print(Platform.I);
    print(platform.toString());
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
                child: InputDetailsColumn(),
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

class TwoColumnLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputDetailsColumn(),
        ),
        Expanded(
          child: ImageColumn(),
        ),
      ],
    );
  }
}

class InputDetailsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firstNameTextFieldController = TextEditingController();
    final lastNameTextFieldController = TextEditingController();
    final ageTextFieldController = TextEditingController();
    final medicalRecordNumberTextFieldController = TextEditingController();

    return
      Padding(padding: EdgeInsets.all(16),child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(labelText: Strings.firstName),
            controller: firstNameTextFieldController,
          ),
          TextField(
            decoration: InputDecoration(labelText: Strings.lastName),
            controller: lastNameTextFieldController,
          ),
          TextField(
            decoration: InputDecoration(labelText: Strings.age),
            controller: ageTextFieldController,
          ),
          TextField(
            decoration: InputDecoration(labelText: Strings.medicalRecordNumber),
            controller: medicalRecordNumberTextFieldController,
          ),
          SizedBox(height: 16,),
          Text(
            Strings.noDetailsSharedNote,
          ),
          SizedBox(height: 16,),
          Container(

              width: double.infinity, // Make the button full width
              child:           ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // Set the background color to primary color
                  ),
                  onPressed: () {
                    // context.push('/setting');
                    if (firstNameTextFieldController.text.isNotEmpty &&
                        lastNameTextFieldController.text.isNotEmpty &&
                        ageTextFieldController.text.isNotEmpty &&
                        medicalRecordNumberTextFieldController.text.isNotEmpty) {
                      // If all the fields are not empty
                      // Navigate to the next screen.
                      context.push('/setting');
                    } else {
                      // If the fields are empty show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill all the details"),
                        ),
                      );
                    }
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
