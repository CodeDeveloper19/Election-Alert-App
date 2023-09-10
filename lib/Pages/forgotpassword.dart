import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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

  void _showSnackbarSuccess(message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 280,
          left: 10,
          right: 10,
        ),
        content: AwesomeSnackbarContent(
          title: 'Password Reset Sent',
          titleFontSize: 18,
          message: message,
          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.help,
        ),
      ),
    );
  }

  void _showSnackbarError(message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 280,
          left: 10,
          right: 10,
        ),
        content: AwesomeSnackbarContent(
          title: 'Error!',
          titleFontSize: 18,
          message: message,
          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ),
      ),
    );
  }

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
              child: MyTextField(hintText: 'Email Address', controller: emailController, obscureText: false, iconName: Icon(Icons.email), textCapital: TextCapitalization.none,),
            ),
              Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (emailController.text == ""){
                    _showSnackbarError('Input field is empty');
                  } else {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                      _showSnackbarSuccess('Check your email for the password reset link');
                      context.go('/auth/login');
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'invalid-email'){
                        _showSnackbarError('Email address provided is invalid');
                      } else if (e.code == 'user-not-found') {
                        _showSnackbarError('No user found for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                ),
                child: Center(
                  child: Text(
                    'Reset Password',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      context.go('/auth/signup');
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
                      context.go('/auth/login');
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

