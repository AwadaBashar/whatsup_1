import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/models/messsage.dart';
import 'package:whatsup_1/resources/firebase_repositry.dart';
import 'package:whatsup_1/utils/utilities.dart';
import 'package:whatsup_1/provider/image_upload_provider.dart';
import 'package:whatsup_1/enum/view_state.dart';
import 'package:whatsup_1/widgets/cached_image.dart';

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
String myid;
String recid;
bool isWriting = false;
bool showEmojiPicker = false;
String name;
ScrollController _listScrollController= ScrollController();

FocusNode textFieldFocus = FocusNode();
FirebaseRepository _repository=FirebaseRepository();

ImageUploadProvider _imageUploadProvider;

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

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    if (!mounted) return;
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    if (!mounted) return;
    setState(() {
      showEmojiPicker = true;
    });
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
     timestamp:Timestamp.now(),
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
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
           _listScrollController.animateTo(
             _listScrollController.position.minScrollExtent,
             duration: Duration(milliseconds: 250),
             curve: Curves.easeInOut,
           );
         });
         
        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          reverse: true,
          controller: _listScrollController,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

 Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: snapshot['senderId'] == myid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: snapshot['senderId'] == recid
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }
   Widget senderLayout(Message message) {
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
        child: getMessage(message),
      ),
    );
  }
  getMessage(Message message) {
   return message.type != "image"
        ? Text(
            message.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(url: message.photoUrl)
            : Text("Url was null");
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _repository.uploadImage(
        image: selectedImage,
        receiverId: recid,
        senderId: myid,
        imageUploadProvider: _imageUploadProvider);
  }
  
  Widget receiverLayout(Message message) {
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
        child: getMessage(message),
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

  emojiContainer() {
    return EmojiPicker(
      bgColor: Color(0xff272c35),
      indicatorColor: Color(0xff2b9ed4),
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        if (!mounted) return;
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _imageUploadProvider= Provider.of<ImageUploadProvider>(context);
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
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15),
                  child: CircularProgressIndicator(),
                )
              : Container(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          Container(
          color: Colors.white,
            child: Row(children: <Widget>[
        SizedBox(width: 8.0),
        IconButton(
          icon: Icon(Icons.insert_emoticon),
          onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
              ),
        SizedBox(width: 8.0),
        Expanded(
            child: TextField(
              controller: textFieldController,
              focusNode: textFieldFocus,
              onTap: () => hideEmojiContainer(),
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
            ),
        ),
        GestureDetector(
        onTap: () => pickImage(source: ImageSource.gallery),
        child:Icon(Icons.attach_file,
              size: 30.0, color: Theme.of(context).hintColor),),
        SizedBox(width: 8.0),
        GestureDetector( 
          onTap: () => pickImage(source: ImageSource.camera),
          child: Icon(Icons.camera_alt,
              size: 30.0, color: Theme.of(context).hintColor),),

        SizedBox(width: 8.0),
        IconButton(icon: Icon(Icons.send), onPressed:(){sendMessage(); textFieldController.clear();}),
      ],),
          ), 
        ],
      ),
    );
  }
}
