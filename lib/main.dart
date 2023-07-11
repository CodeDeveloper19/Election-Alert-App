import 'package:flutter/material.dart';
import 'package:election_alert_app/Pages/onboarding.dart';
import 'package:election_alert_app/Pages/login.dart';
import 'package:election_alert_app/Pages/signup.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const OnBoarding(),
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp()
      },
    );
  }
}
