

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

  Future<String> uploadVideoToStorage(File videoFile) =>
      _firebaseMethods.uploadVideoToStorage(videoFile);

  void uploadVideoMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setVideoMsg(url, receiverId, senderId);

  
   void uploadVideo({
    @required File video,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider
  }) =>
      _firebaseMethods.uploadVideo(video, receiverId, senderId, imageUploadProvider);

  Future<String> uploadAudioToStorage(String audioFile) =>
      _firebaseMethods.uploadAudioToStorage(audioFile);

  void uploadAudioMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setAudioMsg(url, receiverId, senderId);

  
   void uploadAudio({
    @required String audio,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider
  }) =>
      _firebaseMethods.uploadAudio(audio, receiverId, senderId, imageUploadProvider);

  Future<String> uploadDocToStorage(String docFile) =>
      _firebaseMethods.uploadDocToStorage(docFile);

  void uploadDocMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setDocMsg(url, receiverId, senderId);

  
   void uploadDoc({
    @required String audio,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider
  }) =>
      _firebaseMethods.uploadDoc(audio, receiverId, senderId, imageUploadProvider);
}