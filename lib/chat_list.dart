import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_room.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with WidgetsBindingObserver {
  Iterable<Contact> _contacts=[];
  HashMap<int, String> usermap;
  HashMap<String,String> usermap1=new HashMap<String,String>();
  HashMap<String,String> usermap2=new HashMap<String,String>();
  HashMap<String,bool> userstatus=new HashMap<String,bool>();
  QuerySnapshot users;
  
  getdata() async {
    QuerySnapshot users =
        await Firestore.instance.collection('users').getDocuments();
    return users;
  }
 HashMap<int, String> buildContactedPeople(String userid,HashMap<String,String> x)
{
  
  HashMap<int, String> usersmap = new HashMap<int, String>();
  for (int i = 0; i < users.documents.length; i++) {
    

      if (users.documents[i].data['userid'] == userid)
      {
        List<String> names = List.from(users.documents[i].data['talkedwith']);
        for(int j=0;j<names.length;j++)
        {
          
          usersmap[j] =x[names.elementAt(j)];
        
        }
        return usersmap;
      }
     
    }
    
}
   get2()async{
HashMap<String,String> ids=new HashMap<String,String>();
      for (int i = 0; i < users.documents.length; i++) {
        String fileName=users.documents[i].data['profile'];
   
  ids[users.documents[i].data['Phone']]=fileName;

        
        
        }
    //ids["+96170286007"]="https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";
        return ids;
  }
  // HashMap<int, String> createmap(String x,int lengthTalked) {
  //   HashMap<int, String> usersmap = new HashMap<int, String>();
  //   //HashMap<String,String> usermap1=new HashMap<String,String>();
  //   for (int i = 0; i < users.documents.length; i++) {
  //     usersmap[i] = users.documents[i].data['Phone'];
  //     //usermap1[users.documents[i].data['Phone']]=users.documents[i].documentID;
  //   }
  //   return usersmap;
  // }
  HashMap<String, String> createmap1() {
    //HashMap<int, String> usersmap = new HashMap<int, String>();
    HashMap<String,String> usermap1=new HashMap<String,String>();
    for (int i = 0; i < users.documents.length; i++) {
      //usersmap[i] = users.documents[i].data['Phone'];
      usermap1[users.documents[i].data['Phone']]=users.documents[i].data['userid'];
    }
    return usermap1;
  }
  HashMap<String, bool> createmap3() {
    //HashMap<int, String> usersmap = new HashMap<int, String>();
    HashMap<String,bool> usermap1=new HashMap<String,bool>();
    for (int i = 0; i < users.documents.length; i++) {
      //usersmap[i] = users.documents[i].data['Phone'];
      usermap1[users.documents[i].data['Phone']]=users.documents[i].data['online'];
    }
    return usermap1;
  }
  HashMap<String, String> createmap2() {
    //HashMap<int, String> usersmap = new HashMap<int, String>();
    HashMap<String,String> usermap1=new HashMap<String,String>();
    for (int i = 0; i < users.documents.length; i++) {
      //usersmap[i] = users.documents[i].data['Phone'];
      usermap1[users.documents[i].data['userid']]=users.documents[i].data['Phone'];
    }
    return usermap1;
  }
  Future<String>getid()async{
   final FirebaseUser user = await FirebaseAuth.instance.currentUser();
  return user.uid;
  
  }
String myid;
HashMap<String,String> urls=new HashMap<String,String>();
  @override
  initState() {
    if (!mounted) return;
    getdata().then((results){
      setState(() async{
        users = results;
        create ()async{
     myid=await getid();
     usermap1=createmap1();
      usermap2=createmap2();
      usermap = buildContactedPeople(myid,usermap2);
      userstatus=createmap3();
    }
    
        
       // print("a");
         create2()async{
         urls=await get2();}
      await create();
      await create2();
      });
     
      
      
    
      //print(usermap);
    });

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    didChangeAccessibilityFeatures();
    refreshContacts();
  }

  refreshContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
      if (!mounted) return;
//      var contacts = await ContactsService.getContactsForPhone("8554964652");
      setState(() {
        _contacts = contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (state == AppLifecycleState.resumed){
      print("xxxx");
      Firestore.instance.collection('users').document(user.uid).updateData({
                            'online':true
                          }).catchError((e) {
                            print(e);
                          });

    }
      
    else
     {
       print("yyyy");
       String x=DateFormat('MM-dd – kk:mm').format(DateTime.now());
        Firestore.instance.collection('users').document(user.uid).updateData({
                            'online':false,
                            'lastSeen':x
                          }).catchError((e) {
                            print(e);
                          });


     }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.restricted) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
  String convertnum(String numb)
  {
     numb=numb.toString().replaceAll(new RegExp(r"\s+\b|\b\s"), "");
      if(!numb.contains("+961")){
        numb="+961" + numb;
      
  }
  return numb;
  }
  @override
  Widget build(BuildContext context) {
    List<Contact> ali=[];
    List a=[];
    HashMap<String,String> urls1=new HashMap<String,String>();
    for(int i=0;i<_contacts.length;i++)
    {
      var numb;
      _contacts.elementAt(i).phones.map((f) => numb=(f.value.trim())??" ").toList();
      
      numb=numb.toString().replaceAll(new RegExp(r"\s+\b|\b\s"), "");
      if(!numb.contains("+961")){
        numb="+961" + numb;
      }
      //print(numb);
       if (usermap.containsValue(numb)){
                    //print((c.phones?.elementAt(i).toString().trim()));
                    if(!(a.contains(numb))){
                    ali.add(_contacts.elementAt(i));
                    a.add(numb);
                    }
                   
                    // break;
                  }
                

    }
  urls1=urls;
  print(urls1);
    
    return SafeArea(
      child: _contacts != null
          ? ListView.builder(
              itemCount: ali.length,
              itemBuilder: (BuildContext context, int index) {
                Contact c = ali?.elementAt(index);
                 String numb="";
                    c.phones.map((f) => numb=(f.value.trim())??" ").toList();
                    numb=convertnum(numb);
                return ListTile(
                  onTap: () async{
                    String numb="";
                    c.phones.map((f) => numb=(f.value.trim())??" ").toList();
                    numb=convertnum(numb);
                    //print(usermap1[numb]);

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>ChatRoom(usermap1[numb],c.displayName,urls1[numb],c,userstatus[numb])));
                  },
                  leading: (c.avatar != null && c.avatar.length > 0)
                      ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                      : CircleAvatar(backgroundImage: NetworkImage(urls1[numb])),
              
                  title: Text(c.displayName ?? ""),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
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

