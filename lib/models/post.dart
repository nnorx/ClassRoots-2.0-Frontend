import 'package:classroots/models/section.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/models/class.dart';

class PostModel {
  final List<dynamic> tags;
  final int likeCount;
  final List<dynamic> likes;
  final int commentCount;
  final int shareCount;
  final bool blocked;
  final bool deleted;
  final String id;
  final UserModel author;
  final String description;
  final ClassModel classInfo;
  final SectionModel section;
  final List<dynamic> images;
  final DateTime updated;
  final DateTime created;

  PostModel.fromJson(Map data)
      : this.tags = data['tags'],
        this.likeCount = data['likeCount'],
        this.likes = data['likes'],
        this.commentCount = data['commentCount'],
        this.shareCount = data['shareCount'],
        this.blocked = data['blocked'],
        this.deleted = data['deleted'],
        this.id = data['_id'],
        this.author = UserModel.fromJson(data['author']),
        this.description = data['description'],
        this.classInfo = ClassModel.fromJson(data['class']),
        this.section = SectionModel.fromJson(data['section']),
        this.images = data['images'],
        this.updated = DateTime.fromMillisecondsSinceEpoch(data['updated']),
        this.created = DateTime.fromMillisecondsSinceEpoch(data['created']);
}
