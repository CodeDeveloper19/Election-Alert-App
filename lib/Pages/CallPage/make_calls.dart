import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

class MakeCall extends StatefulWidget {
  const MakeCall({super.key});

  @override
  State<MakeCall> createState() => _MakeCallState();
}

class _MakeCallState extends State<MakeCall> {

  void onButtonPressed (value) {
    setState(() {
      _phoneNumberController.addListener(_handleTextChange);
      _focusNode.requestFocus();
      if (value == 'delete') {
        if (_phoneNumberController.text.isNotEmpty) {
          _phoneNumberController.text =
      _phoneNumberController.text.substring(0, _phoneNumberController.text.length - 1);
        }
      } else {
        _phoneNumberController.text += value;
      }
    });
  }

  TextEditingController _phoneNumberController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();

  final Uri uri = Uri(scheme: 'tel', path: '09135098615');

  void _handleTextChange () {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    if (_phoneNumberController.selection.start !=
        _phoneNumberController.text.length) {
      _phoneNumberController.selection = TextSelection.collapsed(
        offset: _phoneNumberController.text.length,
      );
    }
  }

  @override

  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType){
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300, // Set your desired color
                        width: 2.0, // Set your desired width
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Expanded(
                      //   flex: 6,
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     // controller: _scrollController,
                      //     child: TextFormField(
                      //       // enabled: false,
                      //       decoration: InputDecoration(
                      //         border: InputBorder.none, // Disable the underline
                      //       ),
                      //       keyboardType: TextInputType.none,
                      //       controller: _phoneNumberController,
                      //       style: TextStyle(
                      //           fontSize: 50,
                      //           color: Colors.black
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: Container(
                          child: TextFormField(
                            // enabled: false,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              border: InputBorder.none, // Disable the underline
                            ),
                            keyboardType: TextInputType.none,
                            controller: _phoneNumberController,
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.black
                            ),
                          ),
                          width: 200,
                        )
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            onButtonPressed('delete');
                          },
                          icon: Icon(Icons.backspace, color: Colors.blue[600],),
                        )
                      ),
                    ],
                  )
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialButton(number: '1', onPressed: onButtonPressed),
                        DialButton(number: '2', onPressed: onButtonPressed),
                        DialButton(number: '3', onPressed: onButtonPressed),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialButton(number: '4', onPressed: onButtonPressed),
                        DialButton(number: '5', onPressed: onButtonPressed),
                        DialButton(number: '6', onPressed: onButtonPressed),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialButton(number: '7', onPressed: onButtonPressed),
                        DialButton(number: '8', onPressed: onButtonPressed),
                        DialButton(number: '9', onPressed: onButtonPressed),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialButton(number: '*', onPressed: onButtonPressed),
                        DialButton(number: '0', onPressed: onButtonPressed),
                        DialButton(number: '#', onPressed: onButtonPressed,),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                              onPressed: () async {
                                await launchUrl(uri);
                                // FlutterPhoneDirectCaller.callNumber('09135098615');
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone, color: Colors.white,),
                                  SizedBox(width: 5,),
                                  Text('Call', style: TextStyle(color: Colors.white),)
                                ],
                              )
                          ),
                          decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.all(Radius.circular(30))
                          ),
                        ),
                        // DialButton(number: 'delete', icon: Icons.backspace, onPressed: onButtonPressed,),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }
}

class DialButton extends StatelessWidget {
  final String number;
  final IconData? icon;
  final Function(String) onPressed;

  const DialButton({required this.number, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.all(10.0),
        // padding: EdgeInsets.all(5),
        height: 60,
        width: 60,
        child: TextButton(
          onPressed: () {
            onPressed(number);
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          child: icon != null ? Icon(
            icon,
            size: 36.0,
            color: Colors.blue,
          )
              : Text(
            number,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30)
        ),
      );
    }
}
