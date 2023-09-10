import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late SharedPreferences preferences;

  final firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  final _controller = PageController(
    initialPage: 0
  );

  void initState() {
    super.initState();
    init();
  }

  late int _pageNumber = 1;
  bool _isAlert = false;

  late bool? _isAlertSave;
  late String timeAgo = '';

  Map<String, dynamic> _activity = {};

  Future init() async {
    preferences = await SharedPreferences.getInstance();
    await retrieveActivityList();

    _isAlertSave = preferences.getBool('alert_notifications');

    if (_isAlertSave != null) {
      setState(() {
        _isAlert = _isAlertSave!;
      });
    }
  }

  Future<void> retrieveActivityList () async {
    String? jsonData = preferences.getString('activity');
    if (jsonData != null) {
      Map<String, dynamic> storedData = jsonDecode(jsonData);
      storedData = await convertTimeAgo(storedData);
      setState(() {
        _activity = storedData;
      });
    }
  }

  Future<Map<String, dynamic>> convertTimeAgo (Map<String, dynamic> storedData) async {
    Map<String, dynamic> updatedMap = {};
    // Iterate over the original map and update keys in the new map
    storedData.forEach((key, value) {
      DateTime dateTime = DateTime.parse(key);
      timeAgo = timeago.format(dateTime, locale: 'en_short');
      updatedMap[key] = value;
      updatedMap[key][2] = timeAgo;
    });
    return updatedMap;
  }


  Future<void> savingNotifications () async {
    await preferences.setBool('alert_notifications', _isAlert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 120,
              margin: EdgeInsets.only(bottom: 15),
              child: TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.arrow_back_rounded),
                    Text('Back to Map', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                  ],
                ),
              ),
            ),
            Text('Notifications', style: TextStyle(fontFamily: 'OpenSans', fontSize: 25, fontWeight: FontWeight.w500,),),
            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Text('We may send you important notifications on alert levels and trends concerning electoral violence outside of your notifications settings', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, color: Colors.black45),),
            ),
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _controller.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut
                      );
                    },
                    child: Text('Activity', style: TextStyle(color: Colors.black45, fontSize: 15),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(_pageNumber == 1 ?  Colors.green[600] : Colors.transparent),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut
                      );
                    },
                    child: Text('Settings', style: TextStyle(color: Colors.black45, fontSize: 15),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(_pageNumber == 2 ?  Colors.green[600] : Colors.transparent,),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 380,
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _pageNumber = index + 1;
                  });
                },
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 30, bottom: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () async {
                                  preferences.setString('activity', '{}');
                                  setState(() {
                                    _activity = {};
                                  });
                                },
                                child: Text('Clear All', style: TextStyle(color: Colors.blue[200], fontStyle: FontStyle.italic),)
                            ),
                          ),
                          (_activity.isEmpty) ? Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text('There is no recent activity here', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),),
                              SizedBox(
                                height: 10,
                              ),
                              Image.asset('assets/icons/empty.png', height: 70, width: 70,)
                            ],
                          ) : Column(
                            children: _activity.entries.map((entry) {
                              List<dynamic> dateTimeValue = entry.value;
                              return Container(
                                height: 90,
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child:  CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage: (dateTimeValue[1] == 'assets/icons/ic_launcher.png') ? Image.asset(dateTimeValue[1]).image : Image.network(dateTimeValue[1]).image// Image radius
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Election Alert App', style: TextStyle(fontSize: 10, color: Colors.grey[600]),),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  radius: 2.0, // Adjust the size of the circle dot as needed
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(dateTimeValue[2], style: TextStyle(fontSize: 10, color: Colors.grey[600]),),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(dateTimeValue[0],
                                              overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(height: 1.5, fontStyle: FontStyle.italic, color: Colors.grey[800]),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Alert Notifications', style: TextStyle(fontFamily: 'OpenSans', fontSize: 13, fontWeight: FontWeight.w200,)),
                              Switch(
                                value: _isAlert,
                                onChanged: (value) async {
                                  setState(() {
                                    _isAlert = value;
                                  });
                                  try{
                                    await firestore.collection('users/').doc(user!.uid).update({
                                      'alertSave': value,
                                    });
                                  }
                                  catch (e) {
                                    print(e);
                                  }
                                }
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              savingNotifications();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                            ),
                            child: Center(
                              child: Text(
                                'Save Changes',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
