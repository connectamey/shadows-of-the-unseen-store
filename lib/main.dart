import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sou/screens/homescreen.dart';
import 'package:sou/values/routes.dart';
import 'package:sou/values/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
List<CameraDescription> _cameras = <CameraDescription>[];

final _router = GoRouter(
  routes: [
    GoRoute(
      path: Routes.mainScreenRoute,
      builder: (context, state) => HomeScreen(cameras: _cameras,),
    ),
    GoRoute(
      path: Routes.systemCheckScreenRoute,
      builder: (context, state) => PCCheckScreen(),
    ),
  ],
);
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.code);
  }

  runApp(MyApp(cameras: _cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

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





class PCCheckScreen extends StatelessWidget {
  const PCCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(Strings.checkingPC),
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

