import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class NotificationsOnboarding extends StatefulWidget {
  const NotificationsOnboarding({super.key});

  @override
  State<NotificationsOnboarding> createState() => _NotificationsOnboardingState();
}

class _NotificationsOnboardingState extends State<NotificationsOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget> [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                    child: Image.asset('assets/onboarding/notifications_onboarding.png', width: 250, height: 250, fit: BoxFit.contain),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                margin: EdgeInsets.only(top: 50, bottom: 50),
                child: Text(
                  "Stay informed and never miss a beat with our mobile app's personalized notifications for the latest alerts and trends.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.push('/homepage/notifications_onboarding/settings');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                  ),
                  child: Center(
                    child: Text(
                      'Enable Notifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat'
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
