import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:election_alert_app/Components/formbutton.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget> [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Image.asset('assets/login/1.png', width: 280, height: 280, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 2,
            child: LoginForm(),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child:  MyTextField(hintText: 'Username', controller: usernameController, obscureText: false, iconName: const Icon(Icons.person)),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(5, 20, 5, 0),
              child:  MyTextField(hintText: 'Password', controller: passwordController, obscureText: true, iconName: const Icon(Icons.lock)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextButton(
                    // here toggle the bool value so that when you click
                    // on the whole item, it will reflect changes in Checkbox
                      onPressed: () => setState(() => _isChecked = !_isChecked),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                    value: _isChecked,
                                    onChanged: (value){
                                      setState(() => _isChecked = value!);
                                    }
                                )
                            ),
                            // You can play with the width to adjust your
                            // desired spacing
                            const SizedBox(width: 10.0),
                            const Text("Remember me",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ]
                      )
                  )
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child:  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: 10
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: TextButton(
                //     onPressed: () {},
                //     child: const Text(
                //       'Forgot Password?',
                //       style: TextStyle(
                //         color: Colors.black54,
                //         fontSize: 12
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const FormButton(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                const Text(
                "Don't have an account?",
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                  child: const Text(
                    'Register Here',
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
}

