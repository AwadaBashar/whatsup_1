import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/services/auth.dart';
import '../../chat_list.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import '../../new.dart';
import '../../profile.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:whatsup_1/provider/user_provider.dart';
import 'package:whatsup_1/screens/callscreens/pickup/pickup_layout.dart';

class Home extends StatefulWidget {
  
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  String url;
  UserProvider userProvider;
 
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();
    });
  }
  final _tabs = <Widget>[
    Tab(icon: Icon(Icons.camera_alt)),
    Tab(text: 'CHATS'),
    Tab(text: 'STATUS'),
    Tab(text: 'CALLS'),
  ];

  @override
  Widget build(BuildContext context) {
    Future geturl()async{
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String myid=await user.uid;
      String fileName=myid;
       var ref = FirebaseStorage.instance.ref().child(fileName);
      var downloadUrl = await ref.getDownloadURL();
      setState((){url=downloadUrl;});
    }
    
    return PickupLayout(
          scaffold: DefaultTabController(
        length: _tabs.length,
        initialIndex: 1,
        child: Scaffold(
          // top app bar
          appBar: AppBar(
            title: Text('Whatsup'),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.search), onPressed: () {}),
              // IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
              PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'signout',
                          child: Text('SignOut'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Add profile and status',
                          child: Text('My Profile and Status'),
                        )
                      ],
                  onSelected: (value) async {
                    if (value == 'signout') {
                      await _auth.signOut();
                    }
                    else if (value=='Add profile and status')
                    {
                      await geturl();
                      Navigator.push(context,
                                MaterialPageRoute(builder: (context) => MyApp(url)));
                    }
                  })
            ],
            bottom: TabBar(tabs: _tabs),
          ),

          // body (tab views)
          body: TabBarView(
            children: <Widget>[
              TakePictureScreen(
                // Pass the appropriate camera to the TakePictureScreen widget.
                camera: null,
              ),
              //Text('camera'),
              ChatList(),
              Text('status'),
              Text('calls'),
            ],
          ),
          floatingActionButton:FloatingActionButton(
          onPressed: () async{
            await geturl();
            Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>AllContacts(url)));
          },
          child: Icon(Icons.message),
          backgroundColor: Colors.green,
        ),

        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
