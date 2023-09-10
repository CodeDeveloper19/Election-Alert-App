import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _progressVisible = false;

  void updateProgress() {
    setState(() {
      _progressVisible = !_progressVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget> [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget> [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Image.asset('assets/login/1.png', width: 280, height: 280, fit: BoxFit.contain),
                    ),
                  ],
                ),
                LoginForm(onUpdate: updateProgress)
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Visibility(
                  visible: _progressVisible,
                  child: Container(
                    color: Colors.black54,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                Visibility(
                    visible: _progressVisible,
                    child: CircularProgressIndicator()
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {

  LoginForm({super.key, required this.onUpdate});

  final Function() onUpdate;


  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late SharedPreferences preferences;

  final _loginFormKey = GlobalKey<FormState>();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isChecked = false;
  bool _isCheckedAutomatic = false;
  bool _isRevealed = true;

  late String? _emailAddress;
  late String? _password;
  late bool? _remember;
  late bool? _autoSignOut;

  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    preferences = await SharedPreferences.getInstance();

    _remember = preferences.getBool('remember');
    if (_remember != null) {
      setState(() {
        _isChecked = _remember!;
      });
    }

    if (_isChecked){
      _emailAddress = preferences.getString('email');
      _password = preferences.getString('password');
      _autoSignOut = preferences.getBool('autoSignOut');

      setState(() {
        emailAddressController.text = _emailAddress!;
        passwordController.text = _password!;
        _isCheckedAutomatic = _autoSignOut!;
      });
    }
  }

  void _showSnackbar(message, contentType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
          contentType: contentType,
        ),
      ),
    );
  }

  Future<void> savingCredentials () async {
    if (_isChecked){
      await preferences.setString('password', passwordController.text);
      await preferences.setBool('remember', _isChecked);
      await preferences.setBool('autoSignOut', _isCheckedAutomatic);
    } else {
      await preferences.remove('email');
      await preferences.remove('password');
      await preferences.remove('remember');
      await preferences.remove('autoSignOut');
    }
  }

  Future<void> signIn () async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddressController.text,
        password: passwordController.text,
      );
      savingCredentials();
      widget.onUpdate();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar('No user found for that email.', ContentType.failure);
      } else if (e.code == 'wrong-password') {
        _showSnackbar('Wrong password provided for that user.', ContentType.failure);
      } else if (e.code == 'invalid-email:') {
        _showSnackbar('Email address provided is wrong', ContentType.failure);
      } else if (e.code == 'user-disabled') {
        _showSnackbar("This user's account has been disabled", ContentType.failure);
      } else if (e.code == 'too-many-requests'){
        _showSnackbar("Too many failed login attempts, please wait", ContentType.failure);
      }
      widget.onUpdate();
    } catch (e) {
      print(e);
    }
  }

  Future<void> automaticSignOut() async {
    if (_isCheckedAutomatic){
      await Future.delayed(const Duration(minutes: 5));
      await FirebaseAuth.instance.signOut();
    }
  }

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
              child:  MyTextField(hintText: 'Email Address', controller: emailAddressController, obscureText: false, iconName: const Icon(Icons.email), textCapital: TextCapitalization.none,),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(5, 20, 5, 0),
              child:  MyTextField(hintText: 'Password', controller: passwordController, obscureText: _isRevealed, iconName: togglePassword(), textCapital: TextCapitalization.none,),
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
                  child: TextButton(
                    onPressed: () {
                      context.go('/auth/login/forgot');
                    },
                    child:  Text(
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
                ),
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 0),
                child: TextButton(
                  // here toggle the bool value so that when you click
                  // on the whole item, it will reflect changes in Checkbox
                    onPressed: () => setState(() => _isCheckedAutomatic = !_isCheckedAutomatic),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: Checkbox(
                                  value: _isCheckedAutomatic,
                                  onChanged: (value){
                                    setState(() => _isCheckedAutomatic = value!);
                                  }
                              )
                          ),
                          // You can play with the width to adjust your
                          // desired spacing
                          const SizedBox(width: 10.0),
                          const Text("Log out automatically after five minutes?",
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
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.onUpdate();
                  if (emailAddressController.text == "" || passwordController.text == ""){
                    _showSnackbar('One or more input fields are empty', ContentType.failure);
                    widget.onUpdate();
                  } else {
                    signIn();
                    automaticSignOut();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                ),
                child: Center(
                  child: Text(
                    'Sign In',
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
                    "Don't have an account?",
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/auth/signup');
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

