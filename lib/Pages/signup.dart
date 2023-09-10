import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:election_alert_app/Components/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:searchfield/searchfield.dart';
import 'package:flutter/services.dart' show rootBundle;


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

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
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget> [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 70, 0, 0),
                      child: Image.asset('assets/login/2.png', width: 220, height: 220, fit: BoxFit.contain),
                    ),
                  ],
                ),
                SignUpForm(onUpdate: updateProgress)
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
          ),
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  SignUpForm({super.key, required this.onUpdate});

  final Function() onUpdate;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  late SharedPreferences preferences;

  final firestore = FirebaseFirestore.instance;

  final _signupFormKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  bool _isRevealed = true;

  List<dynamic> pollingUnitData = [];

  final List<String> electionRoleItems = ['Select your electoral role', 'Electoral Official', 'Security Operative'];
  String selectedItem = 'Select your electoral role';

  TextEditingController searchController = TextEditingController();

  late double longitude;
  late double latitude;

  final List<String> pollingStates = [
    "Select your polling unit's state",
    "Abia",
    "Adamawa",
    "Akwa Ibom",
    "Anambra",
    "Bauchi",
    "Bayelsa",
    "Benue",
    "Borno",
    "Cross River",
    "Delta",
    "Ebonyi",
    "Edo",
    "Ekiti",
    "Enugu",
    "FCT - Abuja",
    "Gombe",
    "Imo",
    "Jigawa",
    "Kaduna",
    "Kano",
    "Katsina",
    "Kebbi",
    "Kogi",
    "Kwara",
    "Lagos",
    "Nasarawa",
    "Niger",
    "Ogun",
    "Ondo",
    "Osun",
    "Oyo",
    "Plateau",
    "Rivers",
    "Sokoto",
    "Taraba",
    "Yobe",
    "Zamfara"
  ];
  String selectedState = "Select your polling unit's state";

  late String userPhoneNumber = '';
  bool _isPhoneNumberValid = false;

  void updatePhoneNumber (String a) {
    setState(() {
      userPhoneNumber = a;
    });
  }

  void updateIsPhoneNumberValid (bool a) {
    setState(() {
      _isPhoneNumberValid = a;
    });
  }

  Future<void> loadJsonData(a) async {
    final jsonString = await rootBundle.loadString('assets/polling_units_$a.json');
    final jsonResponse = json.decode(jsonString);

    setState(() {
      pollingUnitData = jsonResponse;
    });
  }

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
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> savingCredentials () async {
    await preferences.setString('password', passwordController.text);
    await preferences.setString('activity', '{}');
  }

  Future uploadUserDetails (User? user) async {
    try{
      await firestore.collection('users/').doc(user!.uid).set({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phoneNumber': userPhoneNumber,
        'electoralRole': selectedItem,
        'emailAddressVerified': false,
        'phoneNumberVerified': false,
        'alertSave': false,
        'pollingAddress': '${searchController.text}, $selectedState State, Nigeria',
        'pollingAddressLatitude': latitude,
        'pollingAddressLongitude': longitude,
        'imageLink': 'https://firebasestorage.googleapis.com/v0/b/election-alert-app-fa31b.appspot.com/o/default_image%2F10.png?alt=media&token=74eba9ef-b70c-44f5-9069-eede7a72e8d1'
      });
    }
    catch (e) {
      print(e);
    }
  }

  Future <bool> searchForLatLng () async {
    try {
      if (searchController.text != '' && selectedState != "Select your polling unit's state"){
        List<Location> locations = await locationFromAddress("${searchController.text}, $selectedState State, Nigeria");
        setState(() {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        });
      } else {
        _showSnackbarError("There is a problem with your polling unit's state or address input");
      }
      return true;
    } catch (e) {
      _showSnackbarError(e);
      print(e);
      return false;
    }
  }

  Future<void> Signup () async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      await savingCredentials();
      await uploadUserDetails(user);
      widget.onUpdate();
      _showSnackbarSuccess('Please confirm your email address');
      context.go('/auth');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackbarError('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showSnackbarError('An account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        _showSnackbarError('Email address provided is invalid');
      }
      widget.onUpdate();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 25, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child:  MyTextField(hintText: 'Firstname', controller: firstNameController, obscureText: false, iconName: const Icon(Icons.account_circle), textCapital: TextCapitalization.words,),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child:  MyTextField(hintText: 'Lastname', controller: lastNameController, obscureText: false, iconName: const Icon(Icons.account_circle), textCapital: TextCapitalization.words,),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 10),
              child:  MyTextField(hintText: 'Email Address', controller: emailController, obscureText: false, iconName: const Icon(Icons.email), textCapital: TextCapitalization.none,),
            ),
            PhoneNumberTextField(userPhoneNumber: userPhoneNumber, isPhoneNumberValid: _isPhoneNumberValid, phoneController: phoneController, updateUserPhoneNumber: updatePhoneNumber, updateIsPhoneNumberValid: updateIsPhoneNumberValid,),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 10),
                padding: const EdgeInsets.only(left: 20, right: 9),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: selectedItem,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  icon: Icon(Icons.arrow_drop_down, size: 24,),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedItem = newValue;
                      });
                    }
                  },
                  items: electionRoleItems.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 10),
                padding: const EdgeInsets.only(left: 20, right: 9),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: selectedState,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  icon: Icon(Icons.arrow_drop_down, size: 24,),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedState = newValue;
                      });
                      if (selectedState != "Select your polling unit's state"){
                        loadJsonData(selectedState);
                      }
                    }
                  },
                  items: pollingStates.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 10),
                padding: const EdgeInsets.only(left: 20, right: 9),
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SearchField(
                  suggestions: pollingUnitData
                      .map((e) => SearchFieldListItem(e, child:
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:16.0),
                    child: Text(e),
                  ),
                  ))
                      .toList(),
                  searchInputDecoration: InputDecoration(
                    hintText: 'Search for your polling unit',
                    hintStyle: TextStyle(color: (selectedState == "Select your polling unit's state") ? Colors.grey[400] : Colors.black54
                    ),
                    border: InputBorder.none, // Remove the underline here
                  ),
                  suggestionDirection: SuggestionDirection.up,
                  controller: searchController,
                  scrollbarAlwaysVisible: true,
                ),
              ),
              ignoring: (selectedState == "Select your polling unit's state") ? true : false
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 25),
              child:  MyTextField(hintText: 'Password', controller: passwordController, obscureText: _isRevealed, iconName: togglePassword(), textCapital: TextCapitalization.none,),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.onUpdate();
                  if (passwordController.text == "" || emailController.text == "" || firstNameController == ""
                  || lastNameController == "" || phoneController == ""
                  || searchController.text == "" || selectedItem == 'Select your electoral role'
                  || selectedState == "Select your polling unit's state"){
                    widget.onUpdate();
                    _showSnackbarError('One or more input fields are empty');
                  } else {
                    bool response = await searchForLatLng();
                    if (response) {
                      Signup();
                    }
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

