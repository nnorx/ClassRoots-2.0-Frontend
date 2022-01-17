import 'package:classroots/models/user.dart';

class PostCommentModel {
  bool deleted;
  bool blocked;
  String id;
  String post;
  UserModel user;
  String comment;
  DateTime updated;
  DateTime created;

  PostCommentModel.fromJson(Map data) {
    this.deleted = data['deleted'];
    this.blocked = data['blocked'];
    this.id = data['_id'];
    this.post = data['post'];
    this.user = UserModel.fromJson(data['user']);
    this.comment = data['comment'];
    this.updated = DateTime.fromMillisecondsSinceEpoch(data['updated']);
    this.created = DateTime.fromMillisecondsSinceEpoch(data['created']);
  }
}
