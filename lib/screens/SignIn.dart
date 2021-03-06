import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'home/home.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          //Navigator.of(context).pop();

          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if (user != null) {
            QuerySnapshot users =
                await Firestore.instance.collection('users').getDocuments();
            bool found = false;
            for (int i = 0; i < users.documents.length; i++) {
              if (users.documents[i].data['Phone'] == phone) {
                found = true;
                final FirebaseUser user =
                    await FirebaseAuth.instance.currentUser();
                Firestore.instance
                    .collection('users')
                    .document(user.uid)
                    .updateData({'online': true}).catchError((e) {
                  print(e);
                });
                break;
              }
            }
            if (FirebaseAuth.instance.currentUser() != null && found != true) {
              final FirebaseUser user =
                  await FirebaseAuth.instance.currentUser();
              Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .setData({
                'Phone': phone,
                'status': "Hey there ,I'm using whatsup",
                'userid': await user.uid,
                'talkedwith': [],
                'username': 'ali',
                'profile':
                    "https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80"
              }).catchError((e) {
                print(e);
              });
            } else {
              print('You need to be logged in');
            }
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Enter pin:"),
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        AuthCredential credential =
                            PhoneAuthProvider.getCredential(
                                verificationId: verificationId, smsCode: code);

                        AuthResult result =
                            await _auth.signInWithCredential(credential);

                        FirebaseUser user = result.user;

                        if (user != null) {
                          QuerySnapshot users = await Firestore.instance
                              .collection('users')
                              .getDocuments();
                          bool found = false;
                          for (int i = 0; i < users.documents.length; i++) {
                            if (users.documents[i].data['Phone'] == phone) {
                              found = true;
                              final FirebaseUser user =
                                  await FirebaseAuth.instance.currentUser();
                              Firestore.instance
                                  .collection('users')
                                  .document(user.uid)
                                  .updateData({'online': true}).catchError((e) {
                                print(e);
                              });
                              break;
                            }
                          }
                          if (FirebaseAuth.instance.currentUser() != null &&
                              found != true) {
                            final FirebaseUser user =
                                await FirebaseAuth.instance.currentUser();
                            Firestore.instance
                                .collection('users')
                                .document(user.uid)
                                .setData({
                              'Phone': phone,
                              'status': "Hey there ,I'm using whatsup",
                              'userid': await user.uid,
                              'talkedwith': [],
                              'username': 'ali',
                              'profile':
                                  "https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80"
                            }).catchError((e) {
                              print(e);
                            });
                          } else {
                            print('You need to be logged in');
                          }
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Home()));
                        } else {
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xff075e54),
          elevation: 0.0,
          title: Text('Sign in to Whatsup'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(32),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Sign in with phone number",
                    style: TextStyle(
                        color: Color(0xff075e54),
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[200])),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300])),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Mobile Number"),
                    controller: _phoneController,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("LOGIN"),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: () async {
                        QuerySnapshot users = await Firestore.instance
                            .collection('users')
                            .getDocuments();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        await loginAction();
                        final phone = _phoneController.text.trim();

                        loginUser(phone, context);
                        // bool found = false;
                        // for (int i = 0; i < users.documents.length; i++) {
                        //   if (users.documents[i].data['Phone'] == phone) {
                        //     found = true;
                        //     final FirebaseUser user = await FirebaseAuth.instance.currentUser();
                        //        Firestore.instance.collection('users').document(user.uid).updateData({
                        //     'online':true
                        //   }).catchError((e) {
                        //     print(e);
                        //   });
                        //     break;
                        //   }
                        // }
                        // if (FirebaseAuth.instance.currentUser() != null && found!=true) {
                        //    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
                        //   Firestore.instance.collection('users').document(user.uid).setData({
                        //     'Phone': phone,
                        //     'status':"Hey there ,I'm using whatsup",
                        //     'userid':await user.uid,
                        //     'talkedwith':[],
                        //     'username':'ali',
                        //     'profile':"https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80"
                        //   }).catchError((e) {
                        //     print(e);
                        //   });
                        // } else {

                        //   print('You need to be logged in');
                        // }

                        Navigator.pop(context);
                      },
                      color: Color(0xff075e54),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<bool> loginAction() async {
    //replace the below line of code with your login request
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }
}