import 'package:flutter/material.dart';
import 'package:election_alert_app/Pages/onboarding.dart';
import 'package:election_alert_app/Pages/login.dart';
import 'package:election_alert_app/Pages/signup.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:election_alert_app/Pages/forgotpassword.dart';

void main(){
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // void initState() {
  //   super.initState();
  //   initialization();
  // }
  //
  // void initialization() async {
  //   FlutterNativeSplash.remove();
  // }

  @override
  Widget build(BuildContext context) {
    // whenever your initialization is completed, remove the splash screen:
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const OnBoarding(),
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/forgot': (context) => const Forgot()
      },
    );
  }
}
