import 'package:flutter/material.dart';
import 'chat_room.dart';


class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      return ListTile(
        leading: CircleAvatar(
                  radius: 23,
                  child:Icon(Icons.person)),
        title: Text('Contact $index'),
        //trailing: Text(DateTime.now().toString()),
        //// onTap START ////
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatRoom(); // passing data to chat room
          }));
        },
        //// onTap END ////
      );
    });
  }
}
