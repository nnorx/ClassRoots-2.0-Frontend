import 'package:classroots/models/class.dart';

class UserModel {
  bool verified;
  bool profileCreated;
  bool disabled;
  bool blocked;
  bool deleted;
  String id;
  String name;
  String image;
  int sex;
  int dob;
  String email;
  String password;
  String fcmToken;
  int lastLoggedIn;
  dynamic created;
  String username;
  ClassModel classInfo;
  String section;
  int postCount;
  int followingCount;
  int followersCount;

  UserModel.fromJson(Map data) {
    this.verified = data['verified'];
    this.profileCreated = data['profileCreated'];
    this.disabled = data['disabled'];
    this.blocked = data['blocked'];
    this.deleted = data['deleted'];
    this.id = data['_id'];
    this.name = data['name'];
    this.image = data['image'] == null
        ? 'https://classroots.herokuapp.com/logo.png'
        : data['image'];
    this.sex = data['sex'];
    this.dob = data['dob'];
    this.email = data['email'];
    this.password = data['password'];
    this.fcmToken = data['fcmToken'];
    this.lastLoggedIn = data['lastLoggedIn'];
    this.created = data['created'];
    this.username = data['username'];
    if (data['class'] != null) {
      this.classInfo = ClassModel.fromJson(data['class']);
    }
    this.section = data['section'];
    this.postCount = data['postCount'];
    this.followingCount = data['followingCount'];
    this.followersCount = data['followersCount'];
  }
}
