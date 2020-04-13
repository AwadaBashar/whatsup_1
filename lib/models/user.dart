class User {

  String uid;
  String name;
  String profilePhoto;
  
  User(String myid, { this.uid });

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['userid'] = user.uid;
    data['name'] = user.uid;
  
    //data["profile_photo"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['userid'];
    this.name = mapData['userid'];
    
    //this.profilePhoto = mapData['profile_photo'];
  }

}