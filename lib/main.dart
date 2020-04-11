import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/models/user.dart';
import 'package:whatsup_1/screens/SignIn.dart';
import 'package:whatsup_1/screens/wraper.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:whatsup_1/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/provider/image_upload_provider.dart';

Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
final firstCamera = cameras.first;
runApp(Whatsup(firstCamera));
}

class Whatsup extends StatelessWidget {
  CameraDescription firstCamera;
  Whatsup(CameraDescription firstCamera)
  {
    this.firstCamera=firstCamera;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImageUploadProvider>(
      create: (context) => ImageUploadProvider(),
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
          home: LoginScreen(),
          ),
    );
      }
}