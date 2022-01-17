import 'package:classroots/models/class.dart';
import 'package:classroots/models/university.dart';
import 'package:classroots/models/user.dart';

class SubscriptionModel {
  final String id;
  final UserModel subscriber;
  final ClassModel classInfo;
  final DateTime updated;
  final DateTime created;

  SubscriptionModel.fromJson(Map data)
      : this.id = data['_id'],
        this.subscriber = UserModel.fromJson(data['subscriber']),
        this.classInfo = ClassModel.fromJson(data['class']),
        this.updated = DateTime.fromMillisecondsSinceEpoch(data['updated']),
        this.created = DateTime.fromMillisecondsSinceEpoch(data['created']);
}
