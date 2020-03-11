// import 'package:flutter/material.dart';
// import 'package:whatsup_1/services/auth.dart';

// class Register extends StatefulWidget {

//   final Function toggleView;
//   Register({ this.toggleView });

//   @override
//   _RegisterState createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {

//   final AuthService _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   String error = '';

//   // text field state
//   String email = '';
//   String password = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xff075e54),
//         elevation: 0.0,
//         title: Text('Sign up to Whatsup'),
//         actions: <Widget>[
//           FlatButton.icon(
//             icon: Icon(Icons.person,color: Colors.white,),
//             label: Text('Sign In',style: TextStyle(color: Colors.white),),
//             onPressed: () => widget.toggleView(),
//           ),
//         ],
//       ),
//       body: Container(
//         padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: <Widget>[
//               SizedBox(height: 20.0),
//               TextFormField(
//               //  decoration: textInputDecoration.copyWith(hintText: 'email'),
//                 validator: (val) => val.isEmpty ? 'Enter an email' : null,
//                 onChanged: (val) {
//                   setState(() => email = val);
//                 },
//               ),
//               SizedBox(height: 20.0),
//               TextFormField(
//                // decoration: textInputDecoration.copyWith(hintText: 'password'),
//                 obscureText: true,
//                 validator: (val) => val.length < 6 ? 'Enter a password 6+ chars long' : null,
//                 onChanged: (val) {
//                   setState(() => password = val);
//                 },
//               ),
//               SizedBox(height: 20.0),
//               RaisedButton(
//                 color: Colors.white,
//                 child: Text(
//                   'Register',
//                   style: TextStyle(color: Colors.black),
//                 ),
//                 onPressed: () async {
//                   if(_formKey.currentState.validate()){
//                     // print(email);
//                     // print(password);
//                     dynamic result =await _auth.registerWithEmailAndPassword(email, password);
//                     print(result.uid);
//                     if(result == null) {
//                       setState(()=>error = 'Please supply a valid email');
//                     }
//                   }
//                 }
//               ),
//               SizedBox(height: 12.0),
//               Text(
//                 error,
//                 style: TextStyle(color: Colors.red, fontSize: 14.0),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }