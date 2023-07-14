import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:election_alert_app/Components/formbutton.dart';

class Forgot extends StatelessWidget {
  const Forgot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 50),
        child: Column(
          children: <Widget> [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget> [
                  Container(
                    padding: const EdgeInsets.only(top: 50),
                    child: Image.asset('assets/login/3.png', width: 280, height: 280, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ForgotForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotForm extends StatefulWidget {
  const ForgotForm({super.key});

  @override
  State<ForgotForm> createState() => _ForgotFormState();
}

class _ForgotFormState extends State<ForgotForm> {
  final _forgotFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _forgotFormKey,
      child: Container(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20, left: 5, right: 5),
              child: MyTextField(hintText: 'Email Address', controller: emailController, obscureText: false, iconName: Icon(Icons.email)),
            ),
            FormButton(horizontalPadding: 10, buttonText: 'Reset Password'),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child:  Text(
                      'Create New Account',
                      style: TextStyle(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 10
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child:  Text(
                      'Try to Sign-in Again',
                      style: TextStyle(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 10
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

