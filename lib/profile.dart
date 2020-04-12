//import 'dart:html';
import 'dart:io';
//import 'dart:html';

import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
//import 'package:image_picker/image_picker.dart';

class MyApp extends StatefulWidget {
  @override 
  _ProfileState createState()=>_ProfileState();
}
class _ProfileState extends State<MyApp>{
  File _image;
  @override
  Widget build(BuildContext context) {
    Future getImage() async{
      var image=await ImagePicker.pickImage(source:ImageSource.gallery);

      setState(() {
        _image=image;

      });
    }

    Future uploadPic(BuildContext context)async{
      String fileName=basename(_image.path);
      StorageReference firebaseStorageRef=FirebaseStorage.instance.ref().child(fileName); 
      StorageUploadTask uploadTask=firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot= await uploadTask.onComplete;

      setState(() {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Picture Uploaded'),));
      });

    }
   // var FontAwesomeIcons;
        return  MaterialApp(
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
              home:Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xff075e54),
              elevation: 0.0,
              title: Text('Profile and Status'),
            ),
            body:Builder(
              builder: (context)=>Container(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:<Widget>[
                    SizedBox(height: 20.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(alignment: Alignment.center,
                        child: CircleAvatar(
                          radius:100,
                          backgroundColor: Color(0xff075e54),
                          child: ClipOval(
                            child:SizedBox( 
                            width: 180.0,
                            height: 180.0,
                            child:(_image!=null)?Image.file(_image,fit:BoxFit.fill)
                            :Image.network(
                            "   ",
                            fit: BoxFit.fill,
                            ),
                            ),
    
                          ),
                        ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top:60.0),
                          child: IconButton(
                         icon: Icon(Icons.camera_alt
                         ),
                         iconSize: 30.0,
                        onPressed: () {
                         getImage();
                        }
                          ), 
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
                            child:Column(children: <Widget>[
                              Align(alignment:Alignment.centerLeft ,
                              child: Text('UserName',
                              style: TextStyle(
                                color:Colors.black,fontSize:18.0,
                              ),
                              ),
                              ),
                              Align(
                                alignment:Alignment.centerLeft ,
                              child: Text('Ali Masri',
                              style: TextStyle(
                                color:Colors.black,fontSize:20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              ),),
                            ],)
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            child:IconButton(
                              icon: Icon(Icons.edit
                         ),
                         iconSize: 18.0,
                         onPressed: (){},
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0,),
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child:Column(children: <Widget>[
                              Align(alignment:Alignment.centerLeft ,
                              child: Text('Location',
                              style: TextStyle(
                                color:Colors.black,fontSize:18.0,
                              ),
                              ),
                              ),
                              Align(
                                alignment:Alignment.centerLeft ,
                              child: Text('Lebanon',
                              style: TextStyle(
                                color:Colors.black,fontSize:20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              ),),
                            ],)
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            child:IconButton(
                              icon: Icon(Icons.edit
                         ),
                         iconSize: 18.0,
                         onPressed: (){},
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(color:Color(0xff075e54),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    elevation: 4.0,
                    splashColor: Colors.green,
                    child: Text('Cancel',style: TextStyle(color: Colors.white,fontSize:16.0)),
                    ),

                     RaisedButton(color:Color(0xff075e54),
                    onPressed: (){
                     uploadPic(context);
                    },
                    elevation: 4.0,
                    splashColor: Colors.green,
                    child: Text('Submit',style: TextStyle(color: Colors.white,fontSize:16.0)),
                    ),
                  ],
                ),

              ],
            )
          )),
          )
    );
  }
}

