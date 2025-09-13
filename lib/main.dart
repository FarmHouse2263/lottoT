import 'package:flutter/material.dart';
import 'package:lotto/page/login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotto Project',
      home: LoginPages(),
    );
  }
}
//ไปแก้ import ที่อยู่ไฟล์นะเพื่อให้หายแดงที่อยู่ไฟล์ชื่อไม่เหมือนกัน
