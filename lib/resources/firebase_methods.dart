import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import '../models/messsage.dart';
import '../models/user.dart';
//import 'package:skype_clone/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
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

}