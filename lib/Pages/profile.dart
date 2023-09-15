import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election_alert_app/Utilities/upload_images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../Components/phone_number_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter_termii/flutter_termii.dart';


class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final firestore = FirebaseFirestore.instance;

  String _profileTitle = 'My Profile';

  final termii = Termii(
    url: 'https://api.ng.termii.com',
    apiKey: 'TLqnNw9rkOQpWycB8IlIPoXsV2x1swIo1sxSpUWbQh7Sm6lvhzH4MqYOQNFzaR',
    senderId: 'EAA',
  );

  final _controller = PageController(
      initialPage: 0
  );
  final _deleteController = PageController(
    initialPage: 0
  );
  final _profileController = PageController(
      initialPage: 0
  );
  final _verificationFormKey = GlobalKey<FormState>();

  bool _isRevealed = true;
  bool _isNewRevealed = true;
  bool _isRevealedName = true;
  bool _isRevealedPhone = true;
  bool _isRevealedDelete = true;
  bool _isRevealedEmail = true;
  bool _deleteVisible = false;
  bool _profileVisible = false;
  bool _progressVisible = false;

  bool _emailAddressVerified = false;
  bool _phoneNumberVerified = false;

  late String _emailAddress = '';
  late String _profileImageURL = 'https://coolbackgrounds.io/images/backgrounds/white/pure-white-background-85a2a7fd.jpg';
  late String _firstName = '';
  late String _lastName = '';
  late String _phoneNumber = '';
  late String _electoralRole = '';
  late String _pollingAddress = '';


  User? user = FirebaseAuth.instance.currentUser;
  late SharedPreferences preferences;

  final passwordController = TextEditingController();
  final namePasswordController = TextEditingController();
  final phonePasswordController = TextEditingController();
  final deletePasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final emailPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  late String userPhoneNumber = '';
  bool _isPhoneNumberValid = false;

  String currentOTP = '';
  final otpFieldController = TextEditingController();
  StreamController<ErrorAnimationType>? otpErrorController;
  bool canResendOTP = false;
  bool otpHasError = false;
  String otpGeneratedId = '';

  CountdownController _countdownController = CountdownController(autoStart: true);
  //
  // @override
  // void dispose() {
  //   otpFieldController.dispose(); // Dispose of the controller
  //   super.dispose();
  // }

  void initState() {
    otpErrorController = StreamController<ErrorAnimationType>();
    super.initState();
    init();
  }

  Future init () async {
    preferences = await SharedPreferences.getInstance();
    if (user != null) {
      setState(() {
        _emailAddress = user!.email ?? "No email address available";
      });
    } else {
      setState(() {
        _emailAddress = "No user signed in";
      });
    }

    if (preferences.getString('imageLink') != null && preferences.getString('email') == _emailAddress) {
      await getUserDataLocally();
    } else {
      await getUserData();
    }
  }

  Future getUserDataLocally () async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      _firstName = preferences.getString('firstName')!;
      _lastName = preferences.getString('lastName')!;
      _electoralRole = preferences.getString('electoralRole')!;
      _phoneNumber = preferences.getString('phoneNumber')!;
      _pollingAddress = preferences.getString('pollingAddress')!;
      _emailAddressVerified = preferences.getBool('emailAddressVerified')!;
      _phoneNumberVerified = preferences.getBool('phoneNumberVerified')!;
      _profileImageURL = preferences.getString('imageLink')!;
    });
  }

  uploadDataLocally (String a, String b, String c, String d, bool e, bool f, String g, String h) async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString('firstName', a);
      preferences.setString('lastName', b);
      preferences.setString('electoralRole', d);
      preferences.setString('phoneNumber', c);
      preferences.setString('pollingAddress', g);
      preferences.setBool('emailAddressVerified', f);
      preferences.setBool('phoneNumberVerified', e);
      preferences.setString('imageLink', h);
      preferences.setString('email', _emailAddress);
    });
  }

  Future getUserData () async {
    preferences = await SharedPreferences.getInstance();
    try {
      DocumentSnapshot documentSnapshot = await firestore.collection('users').doc(user!.uid).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
        String link = userData['imageLink'];
        String firstName = userData['firstName'];
        String lastName = userData['lastName'];
        String phoneNumber = userData['phoneNumber'];
        String electoralRole = userData['electoralRole'];
        bool emailAddressVerified = userData['emailAddressVerified'];
        bool phoneNumberVerified = userData['phoneNumberVerified'];
        String pollingAddress = userData['pollingAddress'];
        setState(() {
          _profileImageURL = link;
          _firstName = firstName;
          _lastName = lastName;
          _phoneNumber = phoneNumber;
          _electoralRole = electoralRole;
          _phoneNumberVerified = phoneNumberVerified;
          _emailAddressVerified = emailAddressVerified;
          _pollingAddress = pollingAddress;
        });
          uploadDataLocally(firstName, lastName, phoneNumber, electoralRole, phoneNumberVerified, emailAddressVerified, pollingAddress, link);
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  Future <void> sendAlertAsActivity(String a, String b, String c) async {
    String now = DateTime.now().toString();
    Map<String, dynamic> storedData;
    String? jsonData = preferences.getString('activity');
    if (jsonData != null) {
      storedData = jsonDecode(jsonData);
    } else {
      storedData = {};
    }
    storedData[now] = [a, b, c];

// Convert the map to a JSON string
    String activityJson = json.encode(storedData);

    preferences.setString('activity', activityJson);
  }

  Future<void> updatePhoneNumberDetails () async {
    if (userPhoneNumber == '+234' || userPhoneNumber == '' || phonePasswordController.text == '') {
      updateProgress();
      _showSnackbar('One or more input fields are empty', ContentType.failure, 'Error!');
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailAddress,
        password: phonePasswordController.text,
      );
        try{
          await firestore.collection('users/').doc(user!.uid).update({
            'phoneNumber': userPhoneNumber,
            'phoneNumberVerified': false
          });
        }
        catch (e) {
          print(e);
        }
        updateProgress();
        phonePasswordController.text = '';
        phoneNumberController.text = '';
        _showSnackbar("Phone number changed successfully", ContentType.success, 'Success!');
        await sendAlertAsActivity('You changed your phone number', _profileImageURL, '');
        await getUserData();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          _showSnackbar('Wrong password provided for that user.', ContentType.failure, 'Error!');
        } else if (e.code == 'user-disabled') {
          _showSnackbar("This user's account has been disabled", ContentType.failure, 'Error!');
        } else if (e.code == 'too-many-requests'){
          _showSnackbar("Too many failed delete attempts, please wait or reset password", ContentType.failure, 'Error!');
        }
        updateProgress();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> updateNameDetails () async {
    if (firstNameController.text == '' || lastNameController.text == '' || namePasswordController.text == '') {
      updateProgress();
      _showSnackbar('One or more input fields are empty', ContentType.failure, 'Error!');
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailAddress,
          password: namePasswordController.text,
        );
        try{
          await firestore.collection('users/').doc(user!.uid).update({
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
          });
        }
        catch (e) {
          print(e);
        }
        updateProgress();
        firstNameController.text = '';
        lastNameController.text = '';
        namePasswordController.text = '';
        _showSnackbar("First and last names changed successfully", ContentType.success, 'Success!');
        await sendAlertAsActivity('You changed your first and last names', _profileImageURL, '');
        await getUserData();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          _showSnackbar('Wrong password provided for that user.', ContentType.failure, 'Error!');
        } else if (e.code == 'user-disabled') {
          _showSnackbar("This user's account has been disabled", ContentType.failure, 'Error!');
        } else if (e.code == 'too-many-requests'){
          _showSnackbar("Too many failed delete attempts, please wait or reset password", ContentType.failure, 'Error!');
        }
        updateProgress();
      } catch (e) {
        print(e);
      }
    }
  }

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

  _verifyEmail() async {
    updateProgress();
    if(_emailAddressVerified == false) {
      await user?.sendEmailVerification();
      _showSnackbar('A verification link has been sent to your email address. Please relogin to update.', ContentType.help, 'Please Check!');
      updateProgress();
    } else {
      await updateVerificationStatus('emailAddressVerified');
      updateProgress();
      _showSnackbar('Your email address is already verified.', ContentType.success, 'Please Note!');
    }
  }

  void _showSnackbar(message, contentType, title) {
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
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        content: AwesomeSnackbarContent(
          title: title,
          titleFontSize: 18,
          message: message,
          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: contentType,
        ),
      ),
    );
  }

  Future <bool> sendOtpToNumber () async {
    final tokenResponseData = await termii.sendToken(
      destination: _phoneNumber.substring(1),
      pinAttempts: 3, // 3 times
      // pinExpiryTime represents how long the PIN is valid before expiration. The time is in minutes. The minimum time value is 0 and the maximum time value is 60
      pinExpiryTime: 2, // 2 minutes
      pinLength: 4,
      // Right before sending the message, PIN code placeholder will be replaced with generated PIN code.
      pinPlaceholder: "< 1234 >",
      messageText: "Your one time password is < 1234 >. If this wasn't generated by you, please ignore.",
      messageType: MessageType.numeric,
      pinType: MessageType.numeric,
    );
    // Parse the JSON string into a map
    Map<String, dynamic> jsonMap = json.decode(tokenResponseData);
    String pinId = jsonMap['pinId'];
    String smsStatus = jsonMap['smsStatus'];
    int status = jsonMap['status'];
    if (status == 200 && smsStatus == 'Message Sent'){
      setState(() {
        otpGeneratedId = pinId;
      });
      return true;
    } else {
      _showSnackbar('The request returned a status code of $status and $smsStatus', ContentType.failure, 'Error!');
      return false;
    }
  }

  Future <bool> verifyOtp (String otpCode) async {
    final verifyTokenResponseData = await termii.verifyToken(
      pinId: otpGeneratedId,
      pin: otpCode,
    );
    // Parse the JSON string into a map
    Map<String, dynamic> jsonMap = json.decode(verifyTokenResponseData);
    bool isVerified = jsonMap['verified'];
    if (isVerified == true) {
      setState(() {
        _phoneNumberVerified = true;
      });
      await updateVerificationStatus('phoneNumberVerified');
      return true;
    } else {
      _showSnackbar('Phone number verification failed. Check code properly or request new OTP.', ContentType.failure, 'Error');
      return false;
    }
  }

  Future <void> updateVerificationStatus (a) async {
    try{
      await firestore.collection('users/').doc(user!.uid).update({
        a: true,
      });
      await preferences.setBool(a, true);
    }
    catch (e) {
      print(e);
    }
  }

  void updateProgress () {
    setState(() {
      _progressVisible = !_progressVisible;
    });
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailAddress,
        password: deletePasswordController.text,
      );
      await user?.delete();
      await deleteUserDetails();
      _showSnackbar("Account deleted successfully", ContentType.success, 'Success!');
      deletePasswordController.text = '';
      context.pop();
      context.go('/auth');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackbar('Wrong password provided for that user.', ContentType.failure, 'Error!');
      } else if (e.code == 'user-disabled') {
        _showSnackbar("This user's account has been disabled", ContentType.failure, 'Error!');
      } else if (e.code == 'too-many-requests'){
        _showSnackbar("Too many failed delete attempts, please wait or reset password", ContentType.failure, 'Error!');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteUserDetails () async {
    try {
      DocumentReference documentRef = firestore.collection('users/').doc(user!.uid);
      await documentRef.delete();
      await preferences.clear();
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  Future<void> _changePassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailAddress,
        password: passwordController.text,
      );
      await user?.updatePassword(newPasswordController.text);
      _showSnackbar("Password changed successfully", ContentType.success, 'Success!');
      await sendAlertAsActivity('You changed your password', _profileImageURL, '');
      await getUserData();
      updateProgress();
      _controller.jumpToPage(
        1,
      );
      passwordController.text = '';
      newPasswordController.text = '';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackbar('Wrong password provided for that user.', ContentType.failure, 'Error!');
      } else if (e.code == 'user-disabled') {
        _showSnackbar("This user's account has been disabled", ContentType.failure, 'Error!');
      } else if (e.code == 'too-many-requests'){
        _showSnackbar("Too many failed delete attempts, please wait or reset password", ContentType.failure, 'Error!');
      }
      updateProgress();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _changeEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailAddress,
        password: emailPasswordController.text,
      );
      await user?.updateEmail(emailController.text);
      try{
        await firestore.collection('users/').doc(user!.uid).update({
          'emailAddressVerified': false
        });
      }
      catch (e) {
        print(e);
      }
      _showSnackbar("Email Address changed successfully", ContentType.success, 'Success!');
      await sendAlertAsActivity('You changed your email address', _profileImageURL, '');
      await getUserData();
      setState(() {
        _emailAddress = emailController.text;
      });
      updateProgress();
      _controller.jumpToPage(
        1,
      );
      emailPasswordController.text = '';
      emailController.text = '';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackbar('Wrong password provided for that user.', ContentType.failure, 'Error!');
      } else if (e.code == 'user-disabled') {
        _showSnackbar("This user's account has been disabled", ContentType.failure, 'Error!');
      } else if (e.code == 'too-many-requests'){
        _showSnackbar("Too many failed delete attempts, please wait or reset password", ContentType.failure, 'Error!');
      }
      updateProgress();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 65, horizontal: 25),
                    child: SingleChildScrollView(
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          IgnorePointer(
                            ignoring: _deleteVisible || _profileVisible || _progressVisible,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Stack(
                                  alignment: AlignmentDirectional.centerStart,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text('$_profileTitle', style: TextStyle(fontFamily: 'OpenSans', fontSize: 22, fontWeight: FontWeight.w500,),)
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        icon: Icon(Icons.arrow_back_rounded, size: 25,)
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  height: 120,
                                  child: Stack(
                                    children: <Widget>[
                                      Builder(
                                          builder: (BuildContext context){
                                            return CircleAvatar(
                                                radius: 55,
                                                backgroundColor: Colors.grey[300],
                                                backgroundImage: Image.network(_profileImageURL, key: ValueKey(new Random().nextInt(300))).image// Image radius
                                            );
                                          }
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: -10,
                                        child: TextButton(
                                          onPressed: () {
                                          },
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _profileVisible= !_profileVisible;
                                              });
                                            },
                                            icon: Icon(Icons.add_a_photo, color: Colors.white, size: 13,),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                            shape: MaterialStateProperty.all(CircleBorder()),
                                            fixedSize: MaterialStateProperty.all(const Size(43, 43)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(_firstName, style: TextStyle(fontFamily: 'OpenSans', fontSize: 16),),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(_lastName, style: TextStyle(fontFamily: 'OpenSans', fontSize: 16),),
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height - 410,
                                  child: PageView(
                                    controller: _controller,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: <Widget>[
                                      SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Account Details', style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  color: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 40,
                                                              height: 40,
                                                              margin: EdgeInsets.only(right: 15),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.green[600],
                                                              ),
                                                              child: Icon(Icons.email, size: 16, color: Colors.white,),
                                                            ),
                                                            Expanded(
                                                              child: Text(_emailAddress, style: TextStyle(fontFamily: 'OpenSans', color: Colors.black, fontSize: 13)),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: _verifyEmail,
                                                        child: Container(
                                                          height: 30,
                                                          width: 90,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[300],
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Center(
                                                            child: Text((user!.emailVerified || _emailAddressVerified) ? 'Verified' : 'Not Verified', style: TextStyle(fontSize: 11, color: (user!.emailVerified || _emailAddressVerified) ? Colors.green[600] : Colors.red[600]),),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            margin: EdgeInsets.only(right: 15),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.green[600],
                                                            ),
                                                            child: Icon(Icons.phone, size: 16, color: Colors.white,),
                                                          ),
                                                          Text(_phoneNumber, style: TextStyle(fontFamily: 'OpenSans', color: Colors.black, fontSize: 13),),
                                                        ],
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (!_phoneNumberVerified){
                                                            updateProgress();
                                                            bool response = await sendOtpToNumber();
                                                            if (response == true){
                                                              _showSnackbar('An otp code has been sent to your phone number', ContentType.help, 'Please Check!');
                                                              updateProgress();
                                                              _controller.jumpToPage(6);
                                                            } else {
                                                              updateProgress();
                                                            }
                                                          } else {
                                                            _showSnackbar('Phone number is already verified', ContentType.success, 'Please Note!');
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 30,
                                                          width: 90,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[300],
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Center(
                                                            child: Text((_phoneNumberVerified) ? 'Verified' : 'Not Verified', style: TextStyle(fontSize: 11, color: (_phoneNumberVerified) ? Colors.green[600] : Colors.red[600]),),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  color: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            margin: EdgeInsets.only(right: 15),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.green[600],
                                                            ),
                                                            child: Icon(Icons.location_on, size: 16, color: Colors.white,),
                                                          ),
                                                          Container(
                                                            width: 150,
                                                            child: Text(_pollingAddress, style: TextStyle(fontFamily: 'OpenSans', color: Colors.black, fontSize: 13)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  color: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            margin: EdgeInsets.only(right: 15),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.green[600],
                                                            ),
                                                            child: Icon(Icons.work, size: 16, color: Colors.white,),
                                                          ),
                                                          Container(
                                                            width: 150,
                                                            child: Text(_electoralRole, style: TextStyle(fontFamily: 'OpenSans', color: Colors.black, fontSize: 13)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  color: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Account Settings', style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _profileTitle = 'Edit Profile';
                                                    });
                                                    _controller.animateToPage(
                                                        1,
                                                        duration: Duration(milliseconds: 300),
                                                        curve: Curves.easeInOut
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            margin: EdgeInsets.only(right: 15),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.green[600],
                                                            ),
                                                            child: Icon(Icons.edit_note, size: 16, color: Colors.white,),
                                                          ),
                                                          Text('Edit Profile', style: TextStyle(fontFamily: 'OpenSans', color: Colors.green, fontSize: 13),)
                                                        ],
                                                      ),
                                                      Icon(Icons.arrow_forward, color: Colors.green[600],)
                                                    ],
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await preferences.setString('activity', '{}');
                                                    await FirebaseAuth.instance.signOut();
                                                    context.pop();
                                                    context.go('/auth/onboarding');
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            margin: EdgeInsets.only(right: 15),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.red[600],
                                                            ),
                                                            child: Icon(Icons.logout, size: 16, color: Colors.white,),
                                                          ),
                                                          Text('Log Out', style: TextStyle(fontFamily: 'OpenSans', color: Colors.red, fontSize: 13),)
                                                        ],
                                                      ),
                                                      Icon(Icons.arrow_forward, color: Colors.red,)
                                                    ],
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                _controller.jumpToPage(3);
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        margin: EdgeInsets.only(right: 15),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.green[600],
                                                        ),
                                                        child: Icon(Icons.person, size: 16, color: Colors.white,),
                                                      ),
                                                      Text('Change Name', style: TextStyle(fontFamily: 'OpenSans', color: Colors.green, fontSize: 13),)
                                                    ],
                                                  ),
                                                  Icon(Icons.arrow_forward, color: Colors.green[600],)
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _controller.jumpToPage(
                                                  2,
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        margin: EdgeInsets.only(right: 15),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.green[600],
                                                        ),
                                                        child: Icon(Icons.password, size: 16, color: Colors.white,),
                                                      ),
                                                      Text('Change Password', style: TextStyle(fontFamily: 'OpenSans', color: Colors.green, fontSize: 13),)
                                                    ],
                                                  ),
                                                  Icon(Icons.arrow_forward, color: Colors.green[600],)
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _controller.jumpToPage(4);
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        margin: EdgeInsets.only(right: 15),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.green[600],
                                                        ),
                                                        child: Icon(Icons.phone, size: 16, color: Colors.white,),
                                                      ),
                                                      Text('Change Phone Number', style: TextStyle(fontFamily: 'OpenSans', color: Colors.green, fontSize: 13),)
                                                    ],
                                                  ),
                                                  Icon(Icons.arrow_forward, color: Colors.green[600],)
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _controller.jumpToPage(5);
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        margin: EdgeInsets.only(right: 15),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.green[600],
                                                        ),
                                                        child: Icon(Icons.email, size: 16, color: Colors.white,),
                                                      ),
                                                      Text('Change Email Address', style: TextStyle(fontFamily: 'OpenSans', color: Colors.green, fontSize: 13),)
                                                    ],
                                                  ),
                                                  Icon(Icons.arrow_forward, color: Colors.green[600],)
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _deleteVisible = !_deleteVisible;
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        margin: EdgeInsets.only(right: 15),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.red[600],
                                                        ),
                                                        child: Icon(Icons.no_accounts, size: 16, color: Colors.white,),
                                                      ),
                                                      Text('Delete Account', style: TextStyle(fontFamily: 'OpenSans', color: Colors.red, fontSize: 13),)
                                                    ],
                                                  ),
                                                  Icon(Icons.arrow_forward, color: Colors.red,)
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white,),
                                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: 100,
                                              child: TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _profileTitle = 'My Profile';
                                                  });
                                                  _controller.jumpToPage(
                                                    0,
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Icon(Icons.arrow_back_rounded),
                                                    Text('Go Back', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              MyTextField(hintText: 'Password', controller: passwordController, obscureText: _isRevealed, iconName: togglePassword(), textCapital: TextCapitalization.none,),
                                              SizedBox(height: 20,),
                                              MyTextField(hintText: 'New Password', controller: newPasswordController, obscureText: _isNewRevealed, iconName: toggleNewPassword(), textCapital: TextCapitalization.none,),
                                              SizedBox(height: 20,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                  updateProgress();
                                                  _changePassword();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Change Password',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                width: 100,
                                                child: TextButton(
                                                  onPressed: () {
                                                    _controller.jumpToPage(
                                                      1,
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Icon(Icons.arrow_back_rounded),
                                                      Text('Go Back', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              MyTextField(hintText: 'New first name', controller: firstNameController, obscureText: false, iconName: Icon(Icons.person), textCapital: TextCapitalization.words,),
                                              SizedBox(height: 20,),
                                              MyTextField(hintText: 'New last name', controller: lastNameController, obscureText: false, iconName: Icon(Icons.person), textCapital: TextCapitalization.words,),
                                              SizedBox(height: 20,),
                                              MyTextField(hintText: 'Password', controller: namePasswordController, obscureText: _isRevealedName, iconName: toggleNamePassword(), textCapital: TextCapitalization.none,),
                                              SizedBox(height: 20,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                  updateProgress();
                                                  updateNameDetails();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Change Name',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                width: 100,
                                                child: TextButton(
                                                  onPressed: () {
                                                    _controller.jumpToPage(
                                                      1,
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Icon(Icons.arrow_back_rounded),
                                                      Text('Go Back', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              PhoneNumberTextField(userPhoneNumber: userPhoneNumber, isPhoneNumberValid: _isPhoneNumberValid, phoneController: phoneNumberController, updateUserPhoneNumber: updatePhoneNumber, updateIsPhoneNumberValid: updateIsPhoneNumberValid,),
                                              SizedBox(height: 20,),
                                              MyTextField(hintText: 'Password', controller: phonePasswordController, obscureText: _isRevealedPhone, iconName: togglePhonePassword(), textCapital: TextCapitalization.none,),
                                              SizedBox(height: 20,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                  updateProgress();
                                                  updatePhoneNumberDetails();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Change Phone Number',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                width: 100,
                                                child: TextButton(
                                                  onPressed: () {
                                                    _controller.jumpToPage(
                                                      1,
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Icon(Icons.arrow_back_rounded),
                                                      Text('Go Back', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              MyTextField(hintText: 'New email address', controller: emailController, obscureText: false, iconName: Icon(Icons.email), textCapital: TextCapitalization.none,),
                                              SizedBox(height: 20,),
                                              MyTextField(hintText: 'Password', controller: emailPasswordController, obscureText: _isRevealedEmail, iconName: toggleEmailPassword(), textCapital: TextCapitalization.none,),
                                              SizedBox(height: 20,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                  updateProgress();
                                                  _changeEmail();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Change Email Address',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                width: 100,
                                                child: TextButton(
                                                  onPressed: () {
                                                    _controller.jumpToPage(
                                                      1,
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Icon(Icons.arrow_back_rounded),
                                                      Text('Go Back', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Phone Number Verification', style: TextStyle(fontSize: 18)),
                                              SizedBox(
                                                height: 20
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: 'We have sent the verification code to your phone number. ',
                                                      style: TextStyle(color: Colors.grey[600], height: 1.5)
                                                    ),
                                                    TextSpan(
                                                      text: ' Change your phone number?',
                                                      style: TextStyle(
                                                        color: Colors.blue[300],
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () {
                                                          _controller.jumpToPage(4);
                                                        },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: 20
                                              ),
                                              Text(
                                                  (otpHasError) ? "*Please fill up all the cells properly*" : "",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic
                                                ),
                                              ),
                                              Form(
                                                key: _verificationFormKey,
                                                child: Column(
                                                  children: [
                                                    PinCodeTextField(
                                                      appContext: context, 
                                                      length: 4,
                                                      obscureText: true,
                                                      obscuringCharacter: '*',
                                                      blinkWhenObscuring: true,
                                                      keyboardType: TextInputType.number,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          currentOTP = value;
                                                        });
                                                      },
                                                      beforeTextPaste: (text) {
                                                        return true;
                                                      },
                                                      errorAnimationController: otpErrorController,
                                                      controller: otpFieldController,
                                                    ),
                                                    SizedBox(
                                                        height: 20
                                                    ),
                                                    Row(
                                                        children: [
                                                          IgnorePointer(
                                                            ignoring: !canResendOTP,
                                                            child: TextButton(
                                                                onPressed: () async {
                                                                  if (canResendOTP) {
                                                                    await _countdownController.restart();
                                                                    setState(() {
                                                                      canResendOTP = false;
                                                                    }
                                                                    );
                                                                  }
                                                                },
                                                                child: Text('Resend OTP in:', style: TextStyle(
                                                                  color: (canResendOTP) ? Colors.blue[300] : Colors.black54,
                                                                  fontStyle: FontStyle.italic,
                                                                ))
                                                            ),
                                                          ),
                                                          Countdown(
                                                              controller: _countdownController,
                                                              seconds: 120,
                                                              build: (BuildContext context, double time) => Text(
                                                                '${time.toInt()} seconds',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors.black54
                                                                ),
                                                              ),
                                                              interval: Duration(milliseconds: 100),
                                                              onFinished: () {
                                                                setState(() {
                                                                  canResendOTP = true;
                                                                });
                                                              }
                                                          ),
                                                        ]
                                                    ),
                                                    SizedBox(
                                                      height: 20
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        _verificationFormKey.currentState!.validate();
                                                        if (currentOTP.length != 4) {
                                                          otpErrorController!.add(ErrorAnimationType.shake); // Triggering error shake animation
                                                          setState(() {
                                                            otpHasError = true;
                                                          });
                                                        } else {
                                                          updateProgress();
                                                          bool response = await verifyOtp(currentOTP);
                                                          if (response) {
                                                            setState(() {
                                                              otpHasError = false;
                                                              _phoneNumberVerified = true;
                                                            });
                                                            _showSnackbar('You have successfully verified your phone number', ContentType.success, 'Success!');
                                                            _controller.jumpToPage(0);
                                                          }
                                                          otpFieldController.text = '';
                                                          updateProgress();
                                                        }
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Submit',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ]
                                          )
                                        )    
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                              visible: _deleteVisible,
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                                  height: 190,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      color: Colors.grey[100]
                                  ),
                                  child: PageView(
                                    controller: _deleteController,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text('Are you sure you want to delete your account?', textAlign: TextAlign.center,),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _deleteVisible = !_deleteVisible;
                                                    });
                                                  },
                                                  child: Text('No', style: TextStyle(color: Colors.white),),
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                      fixedSize: MaterialStateProperty.all(const Size(70, 30)),
                                                      shape: MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                      ),
                                                      overlayColor: MaterialStateProperty.all(Colors.grey[500])
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                                                  },
                                                  child: Text('Yes', style: TextStyle(color: Colors.white),),
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.red[600]),
                                                      fixedSize: MaterialStateProperty.all(const Size(70, 30)),
                                                      shape: MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                      ),
                                                      overlayColor: MaterialStateProperty.all(Colors.grey[500])
                                                  ),
                                                ),
                                              ],
                                            ) ,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          MyTextField(hintText: 'Password', controller: deletePasswordController, obscureText: _isRevealedDelete, iconName: toggleDeletePassword(), textCapital: TextCapitalization.none,),
                                          SizedBox(
                                              height: 30
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _deleteVisible = !_deleteVisible;
                                                    });
                                                  },
                                                  child: Text('Cancel', style: TextStyle(color: Colors.white),),
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                      fixedSize: MaterialStateProperty.all(const Size(70, 30)),
                                                      shape: MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                      ),
                                                      overlayColor: MaterialStateProperty.all(Colors.grey[500])
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                    _deleteAccount();
                                                  },
                                                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.red[600]),
                                                      fixedSize: MaterialStateProperty.all(const Size(70, 30)),
                                                      shape: MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                      ),
                                                      overlayColor: MaterialStateProperty.all(Colors.grey[500])
                                                  ),
                                                ),
                                              ],
                                            ) ,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Visibility(
                              visible: _profileVisible,
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(30, 15, 30, 20),
                                  height: 200,
                                  width: 280,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      color: Colors.grey[100]
                                  ),
                                  child: PageView(
                                    controller: _profileController,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text('Change profile image', style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                                              CloseButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _profileVisible = !_profileVisible;
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              height: 100,
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 25),
                                                      child: Column(
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () async {
                                                              updateProgress();
                                                              bool boole = await uploadImages().selectGalleryImage();
                                                              if (boole == true){
                                                                await getUserData();
                                                                _showSnackbar('You have successfully changed your profile picture', ContentType.success, 'Success!');
                                                                await sendAlertAsActivity('You changed your profile picture', _profileImageURL, '');
                                                                setState(() {
                                                                  _profileVisible = !_profileVisible;
                                                                });
                                                              } else {
                                                                _showSnackbar('There was an error changing your profile picture', ContentType.failure, 'Error!');
                                                              }
                                                              updateProgress();
                                                            },
                                                            child:  CircleAvatar(
                                                              radius: 30,
                                                              backgroundColor: Colors.white,// Image radius
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                child: Image.asset('assets/profiles/10.png', fit: BoxFit.contain),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text('Gallery Image', style: TextStyle(color: Colors.green[600], fontSize: 10),)
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Column(
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () async {
                                                              updateProgress();
                                                              bool boole = await uploadImages().selectCameraImage();
                                                              if (boole == true){
                                                                await getUserData();
                                                                _showSnackbar('You have successfully changed your profile picture', ContentType.success, 'Success!');
                                                                await sendAlertAsActivity('You changed your profile picture', _profileImageURL, '');
                                                                setState(() {
                                                                  _profileVisible = !_profileVisible;
                                                                });
                                                              } else {
                                                                _showSnackbar('There was an error changing your profile picture', ContentType.failure, 'Error!');
                                                              }
                                                              updateProgress();
                                                            },
                                                            child: CircleAvatar(
                                                              radius: 30,
                                                              backgroundColor: Colors.white,// Image radius
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                child: Image.asset('assets/profiles/11.png', fit: BoxFit.contain),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text('Camera Image', style: TextStyle(color: Colors.green[600], fontSize: 10),)
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                              )
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
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
                ]
            ),
          )
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

  Widget toggleNamePassword () {
    return IconButton(
        onPressed: () {
          setState(() {
            _isRevealedName = !_isRevealedName;
          });
        },
        icon: _isRevealedName ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
    );
  }

  Widget togglePhonePassword () {
    return IconButton(
        onPressed: () {
          setState(() {
            _isRevealedPhone = !_isRevealedPhone;
          });
        },
        icon: _isRevealedPhone ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
    );
  }

  Widget toggleEmailPassword () {
    return IconButton(
        onPressed: () {
          setState(() {
            _isRevealedEmail = !_isRevealedEmail;
          });
        },
        icon: _isRevealedEmail ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
    );
  }

  Widget toggleDeletePassword () {
    return IconButton(
        onPressed: () {
          setState(() {
            _isRevealedDelete = !_isRevealedDelete;
          });
        },
        icon: _isRevealedDelete ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
    );
  }

  Widget toggleNewPassword () {
    return IconButton(
        onPressed: () {
          setState(() {
            _isNewRevealed = !_isNewRevealed;
          });
        },
        icon: _isNewRevealed ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
    );
  }
}
