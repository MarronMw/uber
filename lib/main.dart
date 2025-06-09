import 'package:flutter/material.dart';
import 'package:uber/views/register.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YENDA RIDE Login',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: PhoneLoginPage(),
    );
  }
}
