import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sou/screens/homescreen.dart';
import 'package:sou/values/strings.dart';
import 'package:video_player/video_player.dart';


final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => PCCheckScreen(),
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
