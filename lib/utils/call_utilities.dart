// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:whatsup_1/models/call.dart';
// import 'package:whatsup_1/models/user.dart';
// import 'package:whatsup_1/resources/call_methods.dart';
// import 'package:whatsup_1/screens/callscreens/call_screen.dart';
// import 'package:whatsup_1/utils/utilities.dart';

// class CallUtils {
//   static final CallMethods callMethods = CallMethods();

//   static dial({User from, User to, context}) async {
//     Call call = Call(
//       callerId: from.uid,
//       callerName: from.uid,
//       callerPic: "https://firebasestorage.googleapis.com/v0/b/whatsup-5827e.appspot.com/o/appstore.png?alt=media&token=104752d6-b1f0-442b-a02c-0d4f82a6cf30",
//       //from.profilePhoto,
//       receiverId: to.uid,
//       receiverName: to.uid,
//       receiverPic: "https://firebasestorage.googleapis.com/v0/b/whatsup-5827e.appspot.com/o/appstore.png?alt=media&token=104752d6-b1f0-442b-a02c-0d4f82a6cf30",
//       // to.profilePhoto,
//       channelId: Random().nextInt(1000).toString(),
//     );

//     bool callMade = await callMethods.makeCall(call: call);

//     call.hasDialled = true;

//     if (callMade) {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CallScreen(call: call),
//           ));
//     }
//   }
// }