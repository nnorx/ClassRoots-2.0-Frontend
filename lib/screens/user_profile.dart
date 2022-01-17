import 'package:flutter/material.dart';
import 'package:classroots/utils/api.dart';
import 'package:classroots/models/user.dart';
import 'dart:convert' show jsonDecode;
import 'package:classroots/lists/post_user.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  UserProfileScreen(this.user);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserModel user;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: getUserProfile(widget.user.username),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final response = snapshot.data;
            final body = jsonDecode(response.body);
            user = UserModel.fromJson(body['result']);
          }

          return Theme(
            data: ThemeData(
                primarySwatch: Colors.green,
                fontFamily: 'Raleway',
                accentColor: Theme.of(context).accentColor),
            child: Scaffold(
              appBar: AppBar(
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.user.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${widget.user.postCount} posts')
                  ],
                ),
                actions: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.user.image),
                      ),
                    ],
                  ),
                  SizedBox(width: 4.0),
                ],
                backgroundColor: Theme.of(context).accentColor,
                elevation: 0.0,
              ),
              body: snapshot.hasData
                  ? PostUserList(user)
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          );
        },
      );
}
