import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {

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
                child: Text("Name "),
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
          Expanded(
            child: ListView(children: <Widget>[Text("Hello!"),Text("How are you"),Text("Whatsapp")],), // chat threads
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
        Icon(Icons.send,size: 30.0, color: Theme.of(context).hintColor),
      ],),
          ), 
        ],
      ),
    );
  }
}
