import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsup_1/models/call.dart';
import 'package:whatsup_1/models/messsage.dart';
import 'package:whatsup_1/resources/call_methods.dart';
import 'package:whatsup_1/resources/firebase_repositry.dart';
import 'package:whatsup_1/screens/callscreens/call_screen.dart';
import 'package:whatsup_1/screens/callscreens/pickup/pickup_layout.dart';
import 'package:whatsup_1/utils/permissions.dart';
import 'package:whatsup_1/utils/utilities.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:whatsup_1/provider/image_upload_provider.dart';
import 'package:whatsup_1/enum/view_state.dart';
import 'package:whatsup_1/widgets/cached_image.dart';
import 'models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:video_player/video_player.dart';

class ChatRoom extends StatefulWidget {
  String id;
  String na;
  String profile;
  Contact c;
  bool onl;
  ChatRoom(String id, String na1, String pro, Contact x, bool userstatu) {
    this.id = id;
    na = na1;
    profile = pro;
    c = x;
    onl = userstatu;
  }
  @override
  _ChatRoomState createState() =>
      _ChatRoomState(id, na, profile, c, (onl != true) ? "offline" : "online");
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController textFieldController = TextEditingController();
  String myid;
  String recid;
  bool isWriting = false;
  bool showEmojiPicker = false;
  String name;
  ScrollController _listScrollController = ScrollController();
  QuerySnapshot users;
  QuerySnapshot messages;
  FocusNode textFieldFocus = FocusNode();
  FirebaseRepository _repository = FirebaseRepository();
  String profile;
  ImageUploadProvider _imageUploadProvider;
  Contact c;
  String online;
  HashMap<String, bool> usermap1 = new HashMap<String, bool>();
  HashMap<String, String> usermap2 = new HashMap<String, String>();
  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  VideoPlayerController playerController;
  VoidCallback listener;

  Future _init() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      String customPath = '/flutter_audio_recorder_';
      io.Directory appDocDirectory;
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }

      // can add extension like ".mp4" ".wav" ".m4a" ".aac"
      customPath = appDocDirectory.path +
          customPath +
          DateTime.now().millisecondsSinceEpoch.toString();

      // .wav <---> AudioFormat.WAV
      // .mp4 .m4a .aac <---> AudioFormat.AAC
      // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

      _recorder = FlutterAudioRecorder(customPath,
          audioFormat: AudioFormat.AAC, sampleRate: 22050);
      await _recorder.initialized;
    }
  }

  Future _prepare() async {
    await _init();
    var result = await _recorder.current();
    setState(() {
      _recording = result;
    });
  }

  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _t = t;
      });
    });
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    //result.path;
    _t.cancel();

    setState(() {
      _recording = result;
    });
  }

  getdata() async {
    QuerySnapshot users =
        await Firestore.instance.collection('users').getDocuments();
    return users;
  }

  getmess2() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot users = await Firestore()
        .collection("messages")
        .document(recid)
        .collection(await user.uid)
        .getDocuments();
    return users;
  }

  HashMap<String, bool> createmap3() {
    //HashMap<int, String> usersmap = new HashMap<int, String>();
    HashMap<String, bool> usermap1 = new HashMap<String, bool>();
    for (int i = 0; i < users.documents.length; i++) {
      //usersmap[i] = users.documents[i].data['Phone'];
      usermap1[users.documents[i].data['userid']] =
          users.documents[i].data['online'];
    }
    return usermap1;
  }

  Future<void> setseen() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    for (int i = 0; i < messages.documents.length; i++) {
      await Firestore()
          .collection("messages")
          .document(recid)
          .collection(await user.uid)
          .document(messages.documents[i].documentID)
          .updateData({'seen': "yes"}).catchError((e) {
        print(e);
      });
    }
  }

  HashMap<String, String> createmap4() {
    //HashMap<int, String> usersmap = new HashMap<int, String>();
    HashMap<String, String> usermap1 = new HashMap<String, String>();
    for (int i = 0; i < users.documents.length; i++) {
      //usersmap[i] = users.documents[i].data['Phone'];
      usermap1[users.documents[i].data['userid']] =
          users.documents[i].data['lastSeen'];
    }
    return usermap1;
  }

  _ChatRoomState(String id, String name1, pro, Contact x, String onl) {
    online = onl;
    recid = id;
    name = name1;
    profile = pro;
    c = x;
  }
  Timer timer;
  Timer timer2;
  bool seen;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _prepare();
    });
    const one = const Duration(seconds: 60);
    getdata().then((results) {
      setState(() {
        users = results;
        usermap1 = createmap3();
        usermap2 = createmap4();
        create() async {
          myid = await getid();
          sender = User(myid);

          receiver = User(recid);
        }

        create();
      });
    });
    getmess2().then((results) {
      setState(() {
        messages = results;
        setseen();
      });
    });
    listener = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    timer?.cancel();
    timer2?.cancel();
    super.dispose();
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    if (!mounted) return;
    setState(() {
      showEmojiPicker = false;
    });
  }

  @override
  void deactivate() {
    if (playerController != null) {
      playerController.setVolume(0.0);
      playerController.removeListener(listener);
      super.deactivate();
    }
  }

  showEmojiContainer() {
    if (!mounted) return;
    setState(() {
      showEmojiPicker = true;
    });
  }

  Future<String> getid() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  User sender;
  User receiver;

  static final CallMethods callMethods = CallMethods();

  dial({context}) async {
    Call call = Call(
      callerId: myid,
      callerName: myid,
      callerPic:
          "https://firebasestorage.googleapis.com/v0/b/whatsup-5827e.appspot.com/o/appstore.png?alt=media&token=104752d6-b1f0-442b-a02c-0d4f82a6cf30",
      //from.profilePhoto,
      receiverId: recid,
      receiverName: recid,
      receiverPic:
          "https://firebasestorage.googleapis.com/v0/b/whatsup-5827e.appspot.com/o/appstore.png?alt=media&token=104752d6-b1f0-442b-a02c-0d4f82a6cf30",
      // to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }

  sendMessage() async {
    var text = textFieldController.text;
    Message _message = Message(
        receiverId: recid,
        senderId: myid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
        seen: "not");
    setState(() {
      isWriting = false;
      //String myid
      //print(myid);
    });

    _repository.addMessageToDb(_message, sender, receiver);
  }

  Widget messageList() {
    //this.initState();
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
    bool seen1;
    seen1 = (snapshot['seen'] == "yes") ? true : false;
    Message _message = Message.fromMap(snapshot.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: snapshot['senderId'] == myid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: snapshot['senderId'] == recid
            ? senderLayout(_message)
            : receiverLayout(_message, seen1),
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
        color: Colors.grey,
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

  void createVideo(String x) {
    if (playerController == null) {
      playerController = VideoPlayerController.network(x)
        ..addListener(listener)
        ..setVolume(1.0)
        ..initialize()
        ..play();
    } else {
      if (playerController.value.isPlaying) {
        playerController.pause();
      } else {
        playerController = VideoPlayerController.network(x)
          ..addListener(listener)
          ..setVolume(1.0)
          ..initialize()
          ..play();
      }
    }
  }

  getMessage(Message message) {
    return message.type == "text"
        ? Text(
            message.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : (message.type == "image")
            ? (message.photoUrl != null
                ? CachedImage(
                    message.photoUrl,
                    height: 250,
                    width: 250,
                    radius: 10,
                  )
                : Text("Url was null"))
            : (message.type == "music")
                ? (message.docPath != null
                    ? Row(
                        //mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://firebasestorage.googleapis.com/v0/b/whatsup-5827e.appspot.com/o/music.jpg?alt=media&token=aa1c7377-6879-4236-856e-d41b167e4842")),
                          IconButton(
                              tooltip: "press to play audio",
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                AudioPlayer b = new AudioPlayer();
                                b.play(message.docPath, isLocal: false);
                              }),
                          IconButton(
                              tooltip: "press to stop audio",
                              icon: Icon(Icons.pause),
                              onPressed: () {
                                AudioPlayer b = new AudioPlayer();
                                b.pause();
                              })
                        ],
                      )
                    : Text("URL was null"))
                : (message.type == "document")
                    ? (message.docPath != null
                        ? Column(
                            children: <Widget>[
                              Text(
                                "Press here to download",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                              IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: null)
                            ],
                          )
                        : Text("URL was null"))
                    : (message.type == "video")
                        ? (message.videoUrl != null
                            ? AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        FloatingActionButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    createVideo(
                                                        message.videoUrl);
                                                    playerController.play();
                                                    return Column(children: [
                                                      AlertDialog(
                                                        title: Text(
                                                            "Give the code?"),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        playerController
                                                                            .pause();
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .pause)),
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        playerController
                                                                            .play();
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .play_arrow)),
                                                                  Flexible(
                                                                    child: FlatButton(
                                                                        onPressed: () {
                                                                          playerController
                                                                              .pause();
                                                                          Navigator
                                                                              .pop(
                                                                            context,
                                                                          );
                                                                        },
                                                                        child: Icon(Icons.exit_to_app)),
                                                                  )
                                                                ]),
                                                            AspectRatio(
                                                                aspectRatio:
                                                                    16 / 9,
                                                                child: Container(
                                                                    child: VideoPlayer(
                                                                        playerController)))
                                                          ],
                                                        ),
                                                      )
                                                    ]);
                                                  });
                                            },
                                            child: Icon(Icons.play_arrow))
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Text("Url was null"))
                        : (message.type == "audio")
                            ? (message.docPath != null
                                ? Row(
                                    //mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(profile)),
                                      IconButton(
                                          tooltip: "press to play audio",
                                          icon: Icon(Icons.play_arrow),
                                          onPressed: () {
                                            AudioPlayer b = new AudioPlayer();
                                            b.play(message.path,
                                                isLocal: false);
                                          }),
                                      IconButton(
                                          tooltip: "press to stop audio",
                                          icon: Icon(Icons.pause),
                                          onPressed: () {
                                            AudioPlayer b = new AudioPlayer();
                                            b.pause();
                                          })
                                    ],
                                  )
                                : Text("URL Null"))
                            : Text("Not of type");
  }

  getMessage1(Message message, seen2) {
    return message.type == "text"
        ? Text(
            message.message,
            style: TextStyle(
              color: (seen2 != true) ? Colors.black : Colors.blue,
              fontSize: 16.0,
            ),
          )
        : (message.type == "image")
            ? (message.photoUrl != null
                ? CachedImage(
                    message.photoUrl,
                    height: 250,
                    width: 250,
                    radius: 10,
                  )
                : Text("Url was null"))
            : (message.type == "document")
                ? (message.docPath != null
                    ? Column(
                        children: <Widget>[
                          Text(
                            "Press here to download",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.file_download), onPressed: null)
                        ],
                      )
                    : Text("URL was null"))
                : (message.type == "music")
                    ? (message.docPath != null
                        ? Row(
                            //mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://firebasestorage.googleapis.com/v0/b/whatsup-5827e.appspot.com/o/music.jpg?alt=media&token=aa1c7377-6879-4236-856e-d41b167e4842")),
                              IconButton(
                                  tooltip: "press to play audio",
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () {
                                    AudioPlayer b = new AudioPlayer();
                                    b.play(message.docPath, isLocal: false);
                                  }),
                              IconButton(
                                  tooltip: "press to stop audio",
                                  icon: Icon(Icons.pause),
                                  onPressed: () {
                                    AudioPlayer b = new AudioPlayer();
                                    b.pause();
                                  })
                            ],
                          )
                        : Text("URL was null"))
                    : (message.type == "video")
                        ? (message.videoUrl != null
                            ? AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        FloatingActionButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    createVideo(
                                                        message.videoUrl);
                                                    playerController.play();
                                                    return Column(children: [
                                                      AlertDialog(
                                                        title: Text(
                                                            "Give the code?"),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        playerController
                                                                            .pause();
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .pause)),
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        playerController
                                                                            .play();
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .play_arrow)),
                                                                  Flexible(
                                                                    child: FlatButton(
                                                                        onPressed: () {
                                                                          playerController
                                                                              .pause();
                                                                          Navigator
                                                                              .pop(
                                                                            context,
                                                                          );
                                                                        },
                                                                        child: Icon(Icons.exit_to_app)),
                                                                  )
                                                                ]),
                                                            AspectRatio(
                                                                aspectRatio:
                                                                    16 / 9,
                                                                child: Container(
                                                                    child: VideoPlayer(
                                                                        playerController)))
                                                          ],
                                                        ),
                                                      )
                                                    ]);
                                                  });
                                            },
                                            child: Icon(Icons.play_arrow))
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Text("Url was null"))
                        : (message.type == "audio")
                            ? (message.path != null
                                ? Row(
                                    //mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(profile)),
                                      IconButton(
                                          tooltip: "press to play audio",
                                          icon: Icon(Icons.play_arrow),
                                          onPressed: () {
                                            AudioPlayer b = new AudioPlayer();
                                            b.play(message.path,
                                                isLocal: false);
                                          }),
                                      IconButton(
                                          tooltip: "press to stop audio",
                                          icon: Icon(Icons.pause),
                                          onPressed: () {
                                            AudioPlayer b = new AudioPlayer();
                                            b.pause();
                                          })
                                    ],
                                  )
                                : Text("URL Null"))
                            : Text("Not of type");
  }

  void pickImage({@required ImageSource source}) async {
    io.File selectedImage = await Utils.pickImage(source: source);
    _repository.uploadImage(
        image: selectedImage,
        receiverId: recid,
        senderId: myid,
        imageUploadProvider: _imageUploadProvider);
  }

  void pickVideo({@required ImageSource source}) async {
    io.File selectedImage = await ImagePicker.pickVideo(source: source);
    _repository.uploadVideo(
        video: selectedImage,
        receiverId: recid,
        senderId: myid,
        imageUploadProvider: _imageUploadProvider);
  }

  void pickAudio({@required String filepath}) async {
    String selectedImage = filepath;
    _repository.uploadAudio(
        audio: selectedImage,
        receiverId: recid,
        senderId: myid,
        imageUploadProvider: _imageUploadProvider);
  }

  void pickDocument({@required String filepath}) async {
    String selectedImage = filepath;
    _repository.uploadDoc(
        audio: selectedImage,
        receiverId: recid,
        senderId: myid,
        imageUploadProvider: _imageUploadProvider);
  }

  void pickMusic({@required String filepath}) async {
    String selectedImage = filepath;
    _repository.uploadMusic(
        audio: selectedImage,
        receiverId: recid,
        senderId: myid,
        imageUploadProvider: _imageUploadProvider);
  }

  Widget receiverLayout(Message message, bool seen1) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topLeft: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage1(message, seen1),
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
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/images.jpg"), fit: BoxFit.cover)),
      child: PickupLayout(
        scaffold: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            titleSpacing: -30.0,
            automaticallyImplyLeading: true,
            title: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ContactDetailsPage(c)));
                },
                leading: CircleAvatar(
                    radius: 20, backgroundImage: NetworkImage(profile)),
                title: Text(
                  name,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                subtitle: Text(
                    (usermap1[recid].toString() == "true")
                        ? "online"
                        : "Last Seen at " + usermap2[recid].toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white))),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.video_call),
                onPressed: () async =>
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? dial(context: context)
                        : {},
              ),
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ChatRoom(
                            recid, name, online, c, profile == "online")));
                  }),
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
              showEmojiPicker
                  ? Container(child: emojiContainer())
                  : Container(),
              Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
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
                    IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () async {
                          if (_recording.status ==
                              RecordingStatus.Initialized) {
                            await _prepare();
                            await _startRecording();
                          }
                        }),
                    SizedBox(width: 6.0),
                    IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: () async {
                          if (_recording.status == RecordingStatus.Recording) {
                            await _stopRecording();
                            pickAudio(filepath: _recording.path);
                            await _prepare();
                          }
                        }),
                    SizedBox(width: 6.0),
                    PopupMenuButton(
                      itemBuilder: (context) {
                        var list = List<PopupMenuEntry<Object>>();
                        list.add(
                          PopupMenuItem(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.photo),
                                Text("Send Picture")
                              ],
                            ),
                            value: 1,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.camera),
                                Text("Open Camera")
                              ],
                            ),
                            value: 2,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.video_library),
                                Text("Send Video")
                              ],
                            ),
                            value: 3,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.picture_as_pdf),
                                Text("Send Document")
                              ],
                            ),
                            value: 4,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.audiotrack),
                                Text("Send Audio")
                              ],
                            ),
                            value: 5,
                          ),
                        );
                        return list;
                      },
                      onSelected: (value) {
                        if (value == 1) {
                          pickImage(source: ImageSource.gallery);
                        }
                        if (value == 2) {
                          pickImage(source: ImageSource.camera);
                        }
                        if (value == 3) {
                          pickVideo(source: ImageSource.gallery);
                        }
                        if (value == 4) {
                          //String docPaths;

                          void _getDocuments() async {
                            try {
                              String x = await FilePicker.getFilePath(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf', 'docx', 'pptx']);
                              pickDocument(filepath: x);
                            } on PlatformException catch (e) {
                              print("Unsupported operation" + e.toString());
                            }
                          }

                          _getDocuments();
                        }
                        if (value == 5) {
                          //String docPaths;

                          void _getDocument() async {
                            try {
                              String x = await FilePicker.getFilePath(
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'mp3',
                                    'm4a',
                                    'flac',
                                    'wav',
                                    'mp4'
                                  ]);
                              pickMusic(filepath: x);
                            } on PlatformException catch (e) {
                              print("Unsupported operation" + e.toString());
                            }
                          }

                          _getDocument();
                        }
                      },
                      icon: Icon(Icons.attach_file),
                    ),
                    // SizedBox(width: 8.0),
                    // GestureDetector(
                    //   onTap: () => pickImage(source: ImageSource.gallery),
                    //   child: Icon(Icons.attach_file,
                    //       size: 30.0, color: Theme.of(context).hintColor),
                    // ),
                    SizedBox(width: 6.0),
                    GestureDetector(
                      onTap: () => pickImage(source: ImageSource.camera),
                      child: Icon(Icons.camera_alt,
                          size: 30.0, color: Theme.of(context).hintColor),
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          sendMessage();
                          textFieldController.clear();
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact);
  final Contact _contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.share),
//            onPressed: () => shareVCFCard(context, contact: _contact),
//          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => ContactsService.deleteContact(_contact),
          ),
          IconButton(icon: Icon(Icons.update), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Name"),
              trailing: Text(_contact.givenName ?? ""),
            ),
            ListTile(
              title: Text("Middle name"),
              trailing: Text(_contact.middleName ?? ""),
            ),
            ListTile(
              title: Text("Family name"),
              trailing: Text(_contact.familyName ?? ""),
            ),
            ListTile(
              title: Text("Prefix"),
              trailing: Text(_contact.prefix ?? ""),
            ),
            ListTile(
              title: Text("Suffix"),
              trailing: Text(_contact.suffix ?? ""),
            ),
            ListTile(
              title: Text("Birthday"),
              trailing: Text(_contact.birthday != null
                  ? DateFormat('dd-MM-yyyy').format(_contact.birthday)
                  : ""),
            ),
            ListTile(
              title: Text("Company"),
              trailing: Text(_contact.company ?? ""),
            ),
            ListTile(
              title: Text("Job"),
              trailing: Text(_contact.jobTitle ?? ""),
            ),
            ListTile(
              title: Text("Account Type"),
              trailing: Text((_contact.androidAccountType != null)
                  ? _contact.androidAccountType.toString()
                  : ""),
            ),
            //AddressesTile(_contact.postalAddresses),
            ItemsTile("Phones", _contact.phones),
            ItemsTile("Emails", _contact.emails)
          ],
        ),
      ),
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);
  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
