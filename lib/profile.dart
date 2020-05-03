//import 'dart:html';
import 'dart:io';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
//import 'package:image_picker/image_picker.dart';

class MyApp extends StatefulWidget {
  @override
  var userProfileUrl;
  MyApp() {
    userProfileUrl = "";
  }
  _ProfileState createState() => _ProfileState(userProfileUrl);
}

class _ProfileState extends State<MyApp> {
  File _image;
  String url;
  String _userna = " ";
  String _status = " ";

  _ProfileState(userProfileUrl) {
    url = userProfileUrl;
  }

  QuerySnapshot users;
  getdata() async {
    QuerySnapshot users =
        await Firestore.instance.collection('users').getDocuments();
    return users;
  }

  @override
  initState() {
    if (!mounted) return;
    getdata().then((results) {
      setState(() {
        Future get() async {
          final FirebaseUser user = await FirebaseAuth.instance.currentUser();
          users = results;
          for (int i = 0; i < users.documents.length; i++) {
            if (users.documents[i].data['userid'] == user.uid) {
              _userna = users.documents[i].data['username'];
              _status = users.documents[i].data['status'];
              break;
            }
          }
        }

        get();
      });
    });
    super.initState();
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your name'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Name', hintText: 'eg. John Smith'),
                onChanged: (value) {
                  setState(() {
                    get() async {
                      _userna = value;
                      final FirebaseUser user =
                          await FirebaseAuth.instance.currentUser();
                      Firestore.instance
                          .collection('users')
                          .document(user.uid)
                          .updateData({'username': value});
                    }

                    get();
                  });
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _asyncInputDialogStatus(BuildContext context) async {
    showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your status'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Status', hintText: 'eg. Nice quote'),
                onChanged: (value) {
                  setState(() {
                    get() async {
                      _status = value;
                      final FirebaseUser user =
                          await FirebaseAuth.instance.currentUser();
                      Firestore.instance
                          .collection('users')
                          .document(user.uid)
                          .updateData({'status': value});
                    }

                    get();
                  });
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
      });
    }

    Future uploadPic(BuildContext context) async {
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String myid = await user.uid;
      String fileName = myid;
      StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      setState(() {
        get() async {
          var ref = FirebaseStorage.instance.ref().child(fileName);
          var downloadUrl = await ref.getDownloadURL();

          Firestore.instance
              .collection('users')
              .document(user.uid)
              .updateData({'profile': downloadUrl});
        }

        get();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Profile Picture Uploaded'),
        ));
      });
    }

    // var FontAwesomeIcons;
    print(url);
    return MaterialApp(
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
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color(0xff075e54),
            elevation: 0.0,
            title: Text('Profile and Status'),
          ),
          body: Builder(
              builder: (context) => Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Color(0xff075e54),
                              child: ClipOval(
                                child: SizedBox(
                                  width: 180.0,
                                  height: 180.0,
                                  child: (_image != null)
                                      ? Image.file(_image, fit: BoxFit.fill)
                                      : Image.network(
                                           "https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: IconButton(
                                icon: Icon(Icons.camera_alt),
                                iconSize: 30.0,
                                onPressed: () {
                                  getImage();
                                }),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'UserName',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _userna,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                                child: IconButton(
                              icon: Icon(Icons.edit),
                              iconSize: 18.0,
                              onPressed: () async {
                                _asyncInputDialog(context);
                              },
                            )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _status,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                                child: IconButton(
                              icon: Icon(Icons.edit),
                              iconSize: 18.0,
                              onPressed: () async {
                                _asyncInputDialogStatus(context);
                              },
                            )),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            color: Color(0xff075e54),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            elevation: 4.0,
                            splashColor: Colors.green,
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0)),
                          ),
                          RaisedButton(
                            color: Color(0xff075e54),
                            onPressed: () {
                              uploadPic(context);
                            },
                            elevation: 4.0,
                            splashColor: Colors.green,
                            child: Text('Submit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0)),
                          ),
                        ],
                      ),
                    ],
                  ))),
        ));
  }
}
