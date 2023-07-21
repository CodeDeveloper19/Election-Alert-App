import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text('My Home Page'),
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // context.go('/onboarding');
              },
              icon: Icon(Icons.logout)
            ),
          ],
        ),
      ),
    );
  }
}
