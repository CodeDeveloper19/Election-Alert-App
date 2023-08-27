import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class reportViolence extends StatefulWidget {
  reportViolence({super.key, required this.distressLevel, required this.typeOfViolence, required this.latitude, required this.longitude, required this.pollingAddress});

  String distressLevel;
  List<String> typeOfViolence;
  double latitude;
  double longitude;
  String pollingAddress;

  final firestore = FirebaseFirestore.instance;

  Future<String> uploadViolenceReport() async {
    String message = '';
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try{
      await firestore.collection('polling_units/').doc('$latitude,$longitude').set({
        'latitude': latitude,
        'longitude': longitude,
        'distressLevel': distressLevel,
        'typeOfViolence': typeOfViolence,
        'pollingAddress': pollingAddress
      });
      message = 'Success!';
    }
    catch (e) {
      print(e);
      message = 'Error!';
    }
    return message;
  }

  @override
  State<reportViolence> createState() => _reportViolenceState();
}

class _reportViolenceState extends State<reportViolence> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
