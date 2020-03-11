// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:whatsup_1/models/user.dart';
// import 'authenticate/authenticate.dart';
// import 'home/home.dart';


// class Wraper extends StatelessWidget {

//   CameraDescription firstCamera;

//  Wraper(CameraDescription firstCamera){
//    this.firstCamera=firstCamera;

//  }
//   @override
//   Widget build(BuildContext context) {

//     final user=Provider.of<User>(context);
//     print(user);
//     if (user==null){
      
//     return Authenticate();
//     }
//     else {
//       return Home(firstCamera);
//     }
//   }
// }