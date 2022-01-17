import 'package:classroots/models/university.dart';

class ClassModel {
  bool deleted;
  String id;
  UniversityModel university;
  String name;
  String code;
  String createdBy;
  DateTime updated;
  DateTime created;

  ClassModel.fromJson(Map data) {
    this.deleted = data['deleted'];
    this.id = data['_id'];
    this.university = UniversityModel.fromJson(data['university']);
    this.name = data['name'];
    this.code = data['code'];
    this.createdBy = data['createdBy'];
    this.updated = DateTime.fromMillisecondsSinceEpoch(data['updated']);
    this.created = DateTime.fromMillisecondsSinceEpoch(data['created']);
  }
}
