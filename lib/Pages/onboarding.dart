import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';

void main(){
  runApp(const OnBoarding());
}

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: OnBoardingSlider(
        totalPage: 3,
        controllerColor: kDefaultIconDarkColor,
        skipTextButton: Text(
          'Skip',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 17,
            color: Colors.green[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:  Text(
          'Login',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 17,
            color: Colors.green[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        headerBackgroundColor: Colors.white,
        finishButtonText: 'Register',
        centerBackground: true,
        finishButtonStyle: FinishButtonStyle(
          backgroundColor: Colors.green[600],
        ),
        background: [
          Container(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: Image.asset('assets/1.png', width: 300, height: 300, fit: BoxFit.contain)
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: Image.asset('assets/2.png', width: 300, height: 300, fit: BoxFit.contain)
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: Image.asset('assets/3.png', width: 300, height: 300, fit: BoxFit.contain)
          ),
        ],
        speed: 1.3,
        pageBodies: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: <Widget> [
                Container(
                  height: 350,
                ),
                Text(
                  'Get Help',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Text(
                      'Receive immediate assistance from security operatives when you contact them on the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: <Widget> [
                Container(
                  height: 370,
                ),
                Text(
                  "Stay Informed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Text(
                      'Stay up-to-date on the latest incidents, trends, and alerts related to electoral violence happening close to you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: <Widget> [
                Container(
                  height: 350,
                ),
                Text(
                  'Ensure Smooth Elections',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Text(
                      'Conduct a secure and seamless election voting process with ease.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}