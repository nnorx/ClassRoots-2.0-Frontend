import 'package:flutter/material.dart';
import 'package:classroots/models/post.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/cards/post.dart';
import 'package:classroots/cards/user.dart';
import 'package:classroots/utils/api.dart';
import 'dart:convert' show jsonDecode;

class PostUserList extends StatefulWidget {
  final UserModel user;

  PostUserList(this.user);

  @override
  _PostUserListState createState() => _PostUserListState();
}

class _PostUserListState extends State<PostUserList> {
  Map<String, PostModel> posts = Map<String, PostModel>();

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: getPostUser(widget.user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));

          try {
            final response = snapshot.data;
            final body = jsonDecode(response.body);
            List<dynamic> result = body['result'];
            result.forEach((item) {
              posts.addAll(
                  {PostModel.fromJson(item).id: PostModel.fromJson(item)});
            });

            if (result.length == 0) {
              return UserCard(widget.user);
            }

            return ListView.builder(
              itemCount: posts.length,
              // itemBuilder: (context, index) => index == 0
              //     ? Column(
              //         children: <Widget>[
              //           UserCard(widget.user),
              //           Container(
              //             color: Colors.grey,
              //           ),
              //           PostCard(posts.values.toList()[index])
              //         ],
              //       )
              //     : PostCard(posts.values.toList()[index]),
              itemBuilder: (BuildContext context, int index) =>
                  PostCard(posts.values.toList()[index]),
            );
          } catch (error) {
            return Center(child: Text(error.toString()));
          }
        },
      );
}
