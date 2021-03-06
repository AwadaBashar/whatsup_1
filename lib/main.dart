import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/chat_list.dart';
import 'package:whatsup_1/models/user.dart';
import 'package:whatsup_1/screens/SignIn.dart';
import 'package:whatsup_1/screens/home/home.dart';
import 'package:whatsup_1/screens/wraper.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:whatsup_1/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/provider/image_upload_provider.dart';
import 'package:whatsup_1/provider/user_provider.dart';
Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
final firstCamera = cameras.first;
//SharedPreferences prefs = await SharedPreferences.getInstance();

runApp(new MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child:MaterialApp(
          title: 'Whatsup_1',
          theme: ThemeData(
            primaryColor: Color(0xff075e54),
            indicatorColor: Colors.white,
            primaryColorDark: Color(0xFF128C7E),
            primaryIconTheme: IconThemeData(
              color: Colors.white,
            ),
            textTheme: TextTheme(
              title: TextStyle(color: Colors.white),
            ),
          ),
          home: await getLandingPage(),
          ),
    )
);
}

// class Whatsup extends StatelessWidget {
//   CameraDescription firstCamera;
//   Whatsup(CameraDescription firstCamera)
//   {
//     this.firstCamera=firstCamera;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child:MaterialApp(
//           title: 'Whatsup_1',
//           theme: ThemeData(
//             primaryColor: Color(0xff075e54),
//             indicatorColor: Colors.white,
//             primaryColorDark: Color(0xFF128C7E),
//             primaryIconTheme: IconThemeData(
//               color: Colors.white,
//             ),
//             textTheme: TextTheme(
//               title: TextStyle(color: Colors.white),
//             ),
//           ),
//           home: await getLandingPage(),
//           ),
//     );
//       }
// }
final FirebaseAuth _auth = FirebaseAuth.instance;
Future<Widget> getLandingPage() async {
  return StreamBuilder<FirebaseUser>(
    stream: _auth.onAuthStateChanged,
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData && (!snapshot.data.isAnonymous)) {
        return Home();
      }

      return  LoginScreen();
    },
  );
}