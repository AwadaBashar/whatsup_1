import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsup_1/models/messsage.dart';
import 'package:whatsup_1/models/user.dart';

import 'firebase_methods.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();





  Future<void> addMessageToDb(Message message, User sender, User receiver) =>
      _firebaseMethods.addMessageToDb(message, sender, receiver);
}