import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

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
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Image.asset('assets/login/2.png', width: 220, height: 220, fit: BoxFit.contain),
                ),
              ],
            ),
            SignUpForm()
          ],
        ),
      )
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _signupFormKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();

  final emailController = TextEditingController();

  bool _isRevealed = true;

  void _showSnackbarSuccess(message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 10,
            right: 10,
            top: 55
        ),
        content: AwesomeSnackbarContent(
          title: 'Account Creation Successful',
          titleFontSize: 18,
          message: message,
          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
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
            bottom: MediaQuery.of(context).size.height - 100,
            left: 10,
            right: 10,
            top: 55
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

  Future<void> Signup () async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      context.go('/auth');
      // await user?.sendEmailVerification();
      _showSnackbarSuccess('Please confirm your email address');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackbarError('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showSnackbarError('An account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        _showSnackbarError('Email address provided is invalid');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 15),
              child:  MyTextField(hintText: 'Email Address', controller: emailController, obscureText: false, iconName: const Icon(Icons.email)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              child:  MyTextField(hintText: 'Password', controller: passwordController, obscureText: _isRevealed, iconName: togglePassword()),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  if (passwordController.text == "" || emailController.text == ""){
                    print('Missing Texts');
                  } else {
                    Signup();
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  const Text(
                    "Already have an account?",
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/auth/login');
                    },
                    child: const Text(
                        'Login Here',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 11
                        )
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget togglePassword () {
    return IconButton(
        onPressed: () {
          setState(() {
            _isRevealed = !_isRevealed;
          });
        },
        icon: _isRevealed ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
    );
  }
}

