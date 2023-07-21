import 'package:election_alert_app/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:election_alert_app/Pages/login.dart';
import 'package:election_alert_app/Pages/onboarding.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return Homepage();
          } else {
            return OnBoarding();
          }
        },
      ),
    );
  }
}
