

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsup_1/models/messsage.dart';
import 'package:whatsup_1/models/user.dart';
import 'package:whatsup_1/provider/image_upload_provider.dart';
import 'firebase_methods.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();





  Future<void> addMessageToDb(Message message, User sender, User receiver){
      _firebaseMethods.addMessageToDb(message, sender, receiver);
      _firebaseMethods.addId(message, sender, receiver);
  }

  Future<User> getUserDetails() => _firebaseMethods.getUserDetails();


  Future<String> uploadImageToStorage(File imageFile) =>
      _firebaseMethods.uploadImageToStorage(imageFile);

  void uploadImageMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setImageMsg(url, receiverId, senderId);

  
   void uploadImage({
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider
  }) =>
      _firebaseMethods.uploadImage(image, receiverId, senderId, imageUploadProvider);
}