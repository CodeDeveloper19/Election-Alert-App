import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class uploadImages extends StatefulWidget {
  uploadImages({super.key});

  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;

  Future<bool> selectGalleryImage() async {
    dynamic img = await pickImage(ImageSource.gallery);
    if (img == null) {
      return false;
    } else {
      await uploadImageToStorage('profileImage', img);
      return true;
    }
  }

  Future<bool> selectCameraImage() async {
    dynamic img = await pickImage(ImageSource.camera);
    if (img == null) {
      return false;
    } else {
      await uploadImageToStorage('profileImage', img);
      return true;
    }
  }

  Future uploadImageToStorage(String childName, Uint8List file) async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    Reference ref = storage.ref().child('user_profile_images/${user!.uid}/$childName');
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();

    uploadDownloadURL(downloadURL);

  }

  Future pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null){
      return await _file.readAsBytes();
    } else {
      print('No Image is selected');
      // return false;
    }
  }

  Future uploadDownloadURL (a) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try{
      await firestore.collection('users/').doc(user!.uid).update({
        'imageLink': a
      });
    }
    catch (e) {
      print(e);
    }
  }

  @override
  State<uploadImages> createState() => _uploadImagesState();
}

class _uploadImagesState extends State<uploadImages> {

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }

}


