import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:whatsup_1/models/messsage.dart';
import 'package:whatsup_1/resources/firebase_repositry.dart';

import 'models/user.dart';
class ChatRoom extends StatefulWidget {
  String id;
  String na;
  ChatRoom(String id,String na1)
  {
    this.id=id;
    na=na1;
    
  } 
  @override
  
  _ChatRoomState createState() => _ChatRoomState(id,na);
}

class _ChatRoomState extends State<ChatRoom> {
 TextEditingController textFieldController = TextEditingController();
 ScrollController _scrollController = new ScrollController();
 
String myid;
String recid;
bool isWriting;
String name;

FirebaseRepository _repository=FirebaseRepository();

  _ChatRoomState(String id,String name1)
  {
    recid=id;
    name=name1;
  }
   initState() {setState(() {
     
   create ()async{
     myid=await getid();
    sender=User(myid);
    receiver=User(recid);}
    create();}); 
     
    

   
  }
Future<String>getid()async{
   final FirebaseUser user = await FirebaseAuth.instance.currentUser();
  return user.uid;
  
  }
User sender;
User receiver;
sendMessage ()async
 {
   
   var text=textFieldController.text;
   Message _message=Message(
     receiverId:recid,
     senderId:myid,
     message:text,
     timestamp:FieldValue.serverTimestamp(),
     type:'text',


   );
   setState((){
     isWriting=false;
     //String myid
    //print(myid);
   
   });

  _repository.addMessageToDb(_message, sender, receiver);
  
   
   
 }
 Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("messages")
          .document(myid)
          .collection(recid)
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }
 Widget chatMessageItem(DocumentSnapshot snapshot) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: snapshot['senderId'] == myid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: snapshot['senderId'] == recid
            ? senderLayout(snapshot)
            : receiverLayout(snapshot),
      ),
    );
  }
   Widget senderLayout(DocumentSnapshot snapshot) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(snapshot),
      ),
    );
  }
  getMessage(DocumentSnapshot snapshot) {
    return Text(
      snapshot['message'],
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    );
  }
  Widget receiverLayout(DocumentSnapshot snapshot) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(snapshot),
      ),
    );
  }

void chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECE5DD),
      appBar: AppBar(
        title: SizedBox(
          width: double.infinity,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                //left: ,
                //top: 0,
                child: CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.person),
                ),
              ),
              Positioned(
                left: 50 + 2.0 * 2 + 8.0,
                top: 8.0 + 2.0,
                child: Text(name),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.video_call), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          Container(
          color: Colors.white,
            child: Row(children: <Widget>[
        SizedBox(width: 8.0),
        Icon(Icons.insert_emoticon,
              size: 30.0, color: Theme.of(context).hintColor),
        SizedBox(width: 8.0),
        Expanded(
            child: TextField(
              controller: textFieldController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
            ),
        ),
        Icon(Icons.attach_file,
              size: 30.0, color: Theme.of(context).hintColor),
        SizedBox(width: 8.0),
        Icon(Icons.camera_alt,
              size: 30.0, color: Theme.of(context).hintColor),
        SizedBox(width: 8.0),
        
        IconButton(icon: Icon(Icons.send), onPressed:(){sendMessage(); textFieldController.clear();_scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          ); }),
      ],),
          ), 
        ],
      ),
    );
  }
}
