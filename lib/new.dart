import 'package:flutter/material.dart';
import 'dart:collection';
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
class AllContacts extends StatefulWidget {


  @override
  _AllContactsState createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts> {
  Iterable<Contact> _contacts=[];
  HashMap<int, String> usermap;
  HashMap<String,String> usermap1=new HashMap<String,String>();
  QuerySnapshot users;
  getdata() async {
    QuerySnapshot users =
        await Firestore.instance.collection('users').getDocuments();
    return users;
  }

  HashMap<int, String> createmap() {
    HashMap<int, String> usersmap = new HashMap<int, String>();
    //HashMap<String,String> usermap1=new HashMap<String,String>();
    for (int i = 0; i < users.documents.length; i++) {
      usersmap[i] = users.documents[i].data['Phone'];
      //usermap1[users.documents[i].data['Phone']]=users.documents[i].documentID;
    }
    return usersmap;
  }
  HashMap<String, String> createmap1() {
    //HashMap<int, String> usersmap = new HashMap<int, String>();
    HashMap<String,String> usermap1=new HashMap<String,String>();
    for (int i = 0; i < users.documents.length; i++) {
      //usersmap[i] = users.documents[i].data['Phone'];
      usermap1[users.documents[i].data['Phone']]=users.documents[i].data['userid'];
    }
    return usermap1;
  }

  @override
  initState() {
    if (!mounted) return;
    getdata().then((results) {
      setState(() {
        users = results;
       // print("a");
      });
      usermap = createmap();
      usermap1=createmap1();
      //print(usermap);
    });

    super.initState();
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

  updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
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
    return 
      MaterialApp(
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
          title: Text('Contacts'),
        ),
        body:SafeArea(
      child: _contacts != null
          ? ListView.builder(
              itemCount: ali.length,
              itemBuilder: (BuildContext context, int index) {
                Contact c = ali?.elementAt(index);
                
                return ListTile(
                  onTap: () {
                    String numb="";
                    c.phones.map((f) => numb=(f.value.trim())??" ").toList();
                    numb=convertnum(numb);
                    //print(usermap1[numb]);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>ChatRoom(usermap1[numb],c.displayName)));
                  },
                  leading: (c.avatar != null && c.avatar.length > 0)
                      ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                      : CircleAvatar(child: Text(c.initials())),
                  title: Text(c.displayName ?? ""),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    )
          ));
      }
}