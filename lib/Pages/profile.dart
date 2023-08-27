import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:election_alert_app/Components/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:election_alert_app/Utilities/upload_images.dart';
import '../Components/phone_number_field.dart';


class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final firestore = FirebaseFirestore.instance;

  String _profileTitle = 'My Profile';

  final _controller = PageController(
      initialPage: 0
  );

  final _deleteController = PageController(
    initialPage: 0
  );

  final _profileController = PageController(
      initialPage: 0
  );

  void initState() {
    super.initState();
    init();
    getUserData();
  }

  Future init () async {
    if (user != null) {
      setState(() {
        _emailAddress = user!.email ?? "No email address available";
      });
    } else {
      setState(() {
        _emailAddress = "No user signed in";
      });
    }
    }

  Future getUserData () async {
    imageCache.clear();
    try {
      DocumentSnapshot documentSnapshot = await firestore.collection('users').doc(user!.uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
        String link = userData['imageLink'];
        String firstName = userData['firstName'];
        String lastName = userData['lastName'];
        String phoneNumber = userData['phoneNumber'];
        String electoralRole = userData['electoralRole'];
        setState(() {
          _profileImageURL = link;
          _firstName = firstName;
          _lastName = lastName;
          _phoneNumber = phoneNumber;
          _electoralRole = electoralRole;
        });
        print('Document exists');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
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
          });
        }
        catch (e) {
          print(e);
        }
        updateProgress();
        phonePasswordController.text = '';
        phoneNumberController.text = '';
        _showSnackbar("Phone number changed successfully", ContentType.success, 'Success!');
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

  bool _isRevealed = true;
  bool _isNewRevealed = true;
  bool _isRevealedName = true;
  bool _isRevealedPhone = true;
  bool _isRevealedDelete = true;
  bool _isRevealedEmail = true;
  bool _deleteVisible = false;
  bool _profileVisible = false;
  bool _progressVisible = false;

  late String _emailAddress;
  String _profileImageURL = 'https://coolbackgrounds.io/images/backgrounds/white/pure-white-background-85a2a7fd.jpg';
  late String _firstName = '';
  late String _lastName = '';
  late String _phoneNumber = '';
  late String _electoralRole = '';


  User? user = FirebaseAuth.instance.currentUser;

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

  void _verifyDetail() {

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
      context.go('/auth');
      deletePasswordController.text = '';
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
      _showSnackbar("Email Address changed successfully", ContentType.success, 'Success!');
      setState(() {
        _emailAddress = emailController.text;
        // _progressVisible = false;
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

  List <Widget> profileList = [
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () async {
          // final Directory appDocDir = await getApplicationDocumentsDirectory();
          // String filePath = '${appDocDir.absolute}/1.png';
          // File file = File(filePath);
          //
          // final imageStorageRef = FirebaseStorage.instance.ref().child('/user_profile_images');
          // await imageStorageRef.putFile(file);
        },
        child: CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/1.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/2.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/3.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/4.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/5.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/6.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/7.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      margin: EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/8.png', fit: BoxFit.contain),
        ),
      ),
    ),
    Container(
      child: InkWell(
        onTap: () {

        },
        child:  CircleAvatar(
          radius: 30, // Image radius
          child: Image.asset('assets/profiles/9.png', fit: BoxFit.contain),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                                    context.pop();
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
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    onTap: _verifyDetail,
                                                    child: Container(
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Center(
                                                        child: Text((user!.emailVerified) ? 'Verified' : 'Not Verified', style: TextStyle(fontSize: 11, color: (user!.emailVerified) ? Colors.green[600] : Colors.red[600]),),
                                                      ),
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
                                                  onTap: _verifyDetail,
                                                  child: Container(
                                                    width: 75,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Center(
                                                      child: Text('Not Verified', style: TextStyle(fontSize: 11, color: Colors.red[600]),),
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
                                                      child: Text('1, Olowotabutabu St., Ira Ojo', style: TextStyle(fontFamily: 'OpenSans', color: Colors.black, fontSize: 13)),
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
                                              await FirebaseAuth.instance.signOut();
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
                                        // MyTextField(hintText: 'New phone number', controller: phoneNumberController, obscureText: false, iconName: Icon(Icons.person), textCapital: TextCapitalization.none,),
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
                                      // height: MediaQuery.of(context).size.height - 800,
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
                                                // padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
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
                                                // padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
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
                            width: 320,
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
                                      child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 25),
                                              child: Column(
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: () {
                                                      _profileController.jumpToPage(
                                                          1
                                                      );
                                                    },
                                                    child:  CircleAvatar(
                                                      radius: 30, // Image radius
                                                      backgroundImage: AssetImage('assets/profiles/1.png'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text('Default Image', style: TextStyle(color: Colors.green[600], fontSize: 10),)
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 25),
                                              child: Column(
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: () async {
                                                      updateProgress();
                                                      bool boole = await uploadImages().selectGalleryImage();
                                                      getUserData();
                                                      setState(() {
                                                        _profileVisible = boole;
                                                        _progressVisible = boole;
                                                      });
                                                      if (boole== false){
                                                        _showSnackbar('You have successfully changed your profile picture', ContentType.success, 'Success!');
                                                      }
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
                                                      getUserData();
                                                      setState(() {
                                                        _profileVisible = boole;
                                                        _progressVisible = boole;
                                                      });
                                                      if (boole == false){
                                                        _showSnackbar('You have successfully changed your profile picture', ContentType.success, 'Success!');
                                                      }
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
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children : <Widget>[
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                _profileController.jumpToPage(
                                                  0,
                                                );
                                              },
                                              child: Icon(Icons.arrow_back_rounded, color: Colors.black),
                                            ),
                                            CloseButton(
                                              onPressed: () {
                                                setState(() {
                                                  _profileVisible = !_profileVisible;
                                                });
                                              },
                                            ),
                                          ]
                                      ),
                                      Container(
                                          height: 100,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: profileList,
                                          )
                                      ),
                                    ]
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
