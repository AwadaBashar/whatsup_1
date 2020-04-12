class User {

  String uid;
  String name;
  String profilePhoto;
  
  User(String myid, { this.uid });

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.uid;
  
    //data["profile_photo"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    //this.profilePhoto = mapData['profile_photo'];
  }

}