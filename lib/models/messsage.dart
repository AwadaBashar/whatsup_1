import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestamp;
  String photoUrl;
  String seen;
  String path;
<<<<<<< HEAD
  String videoUrl;
  String docPath;
=======
>>>>>>> e633e7e02032d41adafd8ccda7c45a93bc7798d2

  Message({this.senderId, this.receiverId, this.type, this.message, this.timestamp,this.seen});

  //Will be only called when you wish to send an image
  Message.imageMessage({this.senderId, this.receiverId, this.message, this.type, this.timestamp, this.photoUrl});
  Message.audioMessage({this.senderId, this.receiverId, this.message, this.type, this.timestamp, this.path});
<<<<<<< HEAD
  Message.videoMessage({this.senderId, this.receiverId, this.message, this.type, this.timestamp, this.videoUrl});
  Message.docMessage({this.senderId, this.receiverId, this.message, this.type, this.timestamp, this.docPath});
=======
>>>>>>> e633e7e02032d41adafd8ccda7c45a93bc7798d2

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['seen']=this.seen;
    return map;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    return map;
  }

  Map toAudioMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['path'] = this.path;
    return map;
  }

<<<<<<< HEAD
  Map toVideoMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['videoUrl'] = this.videoUrl;
    return map;
  }

  Map toDocMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['docPath'] = this.docPath;
    return map;
  }

=======
>>>>>>> e633e7e02032d41adafd8ccda7c45a93bc7798d2
  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photoUrl = map['photoUrl'];
    this.seen=map['seen'];
    this.path=map['path'];
<<<<<<< HEAD
    this.videoUrl=map['videoUrl'];
    this.docPath=map['docPath'];
=======
>>>>>>> e633e7e02032d41adafd8ccda7c45a93bc7798d2
  }


}