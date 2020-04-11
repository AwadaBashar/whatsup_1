import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import '../models/messsage.dart';
import '../models/user.dart';
//import 'package:skype_clone/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsup_1/provider/image_upload_provider.dart';


class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StorageReference _storageReference;
  
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }
   Future<void> addMessageToDb(
      Message message, User sender, User receiver) async {
    var map = message.toMap();
  
    await Firestore()
        .collection("messages")
        .document(message.senderId)
        .collection(message.receiverId)
        .add(map);
    
    return await Firestore()
        .collection("messages")
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
          _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message message;

    message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    // create imagemap
    var map = message.toImageMap();

    // var map = Map<String, dynamic>();
    await Firestore()
        .collection("messages")
        .document(message.senderId)
        .collection(message.receiverId)
        .add(map);
    
    await Firestore()
        .collection("messages")
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  void uploadImage(File image, String receiverId, String senderId,
      ImageUploadProvider imageUploadProvider) async {
    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);
  
    // Hide loading
    imageUploadProvider.setToIdle();

    setImageMsg(url, receiverId, senderId);
  }

}