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

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
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
  
    
    return SafeArea(
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
