import 'package:firebase_storage/firebase_storage.dart';
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
  String x;
  AllContacts()
  {
    x="";
  }



  @override
  _AllContactsState createState() => _AllContactsState(x);
}
 

class _AllContactsState extends State<AllContacts> {
  Iterable<Contact> _contacts=[];
  HashMap<int, String> usermap;
  HashMap<String,String> usermap1=new HashMap<String,String>();
  HashMap<String,String> ids=new HashMap<String,String>();
  HashMap<String, String> statuses=new HashMap<String,String>();
  QuerySnapshot users;
String url;
  _AllContactsState(String x)
  {
    url=x;
  }
  getdata() async {
    QuerySnapshot users =
        await Firestore.instance.collection('users').getDocuments();
    return users;
  }

  createmap() {
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
  get2()async{
HashMap<String, String> ids=new HashMap<String,String>();
      for (int i = 0; i < users.documents.length; i++) {
        String fileName=users.documents[i].data['status'];
   
  ids[users.documents[i].data['Phone']]=fileName;

        
        
        }
    //ids["+96170286007"]="https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";
        return ids;
  }
   get1()async{
HashMap<String, String> ids=new HashMap<String,String>();
      for (int i = 0; i < users.documents.length; i++) {
        String fileName=users.documents[i].data['profile'];
   
  ids[users.documents[i].data['Phone']]=fileName;

        
        
        }
    //ids["+96170286007"]="https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";
        return ids;
  }
  @override
  initState() {
    if (!mounted) return;
    getdata().then((results) {
      setState(() async{
        
        users = results;
        usermap = createmap();
      usermap1=createmap1();
      create() async{
     ids=await  get1();
    
      }
      create2()async{
        statuses=await get2();
      }
      
    await create();
    await create2();
      //print(usermap);
      //print(ids);
       // print("a");
      });
       
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
  print(numb);
  return numb;
  }
  @override
  Widget build(BuildContext context) {
    List<Contact> ali=[];
    List a=[];
    HashMap<String, String> ids1;
    HashMap<String, String> statuses1;
    bool app=true;
    
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
                    
                    if(!(a.contains(numb))){
                    ali.add(_contacts.elementAt(i));
                    a.add(numb);
                    }
                   
                    
                  }
              

    }
    ids1=ids;
    statuses1=statuses;
   
    
    //print(ids1);
  
   
    
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
              itemBuilder: (BuildContext context, int index)  {
                Contact c = ali?.elementAt(index);
                String numb="";
                c.phones.map((f) => numb=(f.value.trim())??" ").toList();
                 numb=convertnum(numb);
                
                return ListTile(
                  onTap: () {
                    
                    
                    numb=convertnum(numb);
                    convertnum(numb);
                    //print();
                    //print(usermap1[numb]);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>ChatRoom(usermap1[numb],c.displayName,ids1[numb],c,true)));
                  },
                  leading: (c.avatar != null && c.avatar.length > 0)
                      ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                      : CircleAvatar(backgroundImage:NetworkImage(ids1[numb])),
                  isThreeLine: true,
                  title: Text(c.displayName ?? ""), subtitle: Text(statuses1[numb]),
                  
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