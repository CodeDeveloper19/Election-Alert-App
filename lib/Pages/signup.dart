import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:election_alert_app/Components/formbutton.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget> [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Image.asset('assets/login/2.png', width: 220, height: 220, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 3,
            child: SignUpForm()
          ),
        ],
      ),
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

  final firstnameController = TextEditingController();

  final lastnameController = TextEditingController();

  final passwordController = TextEditingController();

  final usernameController = TextEditingController();

  final emailController = TextEditingController();

  bool _isRevealed = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child:  MyTextField(hintText: 'Firstname', controller: firstnameController, obscureText: false, iconName: const Icon(Icons.account_circle)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child:  MyTextField(hintText: 'Lastname', controller: lastnameController, obscureText: false, iconName: const Icon(Icons.account_circle)),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child:  MyTextField(hintText: 'Email', controller: emailController, obscureText: false, iconName: const Icon(Icons.email)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              child:  MyTextField(hintText: 'Password', controller: passwordController, obscureText: _isRevealed, iconName: togglePassword()),
            ),
            const FormButton(horizontalPadding: 0, buttonText: 'Sign Up'),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  const Text(
                    "Already have an account?",
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
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

