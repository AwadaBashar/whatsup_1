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
  static final CollectionReference _userCollection =
      _firestore.collection("users");

  static final Firestore _firestore = Firestore.instance;
  
  Future<FirebaseUser> getCurrentUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user;
  }


   Future<void> addId(
      Message message, User sender, User receiver) async {
        await Firestore().collection('users').document(message.receiverId).updateData({'talkedwith': FieldValue.arrayUnion([message.senderId])});
    await Firestore().collection('users').document(message.senderId).updateData({'talkedwith': FieldValue.arrayUnion([message.receiverId])});

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

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();

    return User.fromMap(documentSnapshot.data);
  }

}