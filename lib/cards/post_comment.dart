import 'package:classroots/providers/auth.dart';
import 'package:classroots/providers/post.dart';
import 'package:classroots/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:classroots/models/post_comment.dart';
import 'package:classroots/utils/time.dart';
import 'package:classroots/utils/text.dart';
import 'package:classroots/models/user.dart';

class PostCommentCard extends StatefulWidget {
  final PostCommentModel post;
  PostCommentCard(this.post);

  @override
  _PostCommentCardState createState() => _PostCommentCardState();
}

class _PostCommentCardState extends State<PostCommentCard> {
  UserModel currentUser;
  bool deleted = false;

  _openUserProfile(UserModel user, context) {
    Navigator.of(context).pushNamed('/profile/user/${user.username}');
  }

  @override
  Widget build(BuildContext context) => deleted
      ? Container()
      : StreamBuilder(
          stream: AuthProvider.of(context).currentUser,
          builder: (BuildContext context,
              AsyncSnapshot<UserModel> currentUserSnapshot) {
            if (!currentUserSnapshot.hasData) return Container();
            currentUser = currentUserSnapshot.data;

            return ListTile(
              leading: GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.post.user.image),
                  backgroundColor: Colors.grey,
                ),
                onTap: () {
                  _openUserProfile(widget.post.user, context);
                },
              ),
              title: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      child: Text(
                        '@${widget.post.user.username}',
                        style: DefaultTextStyle.of(context).style.copyWith(
                            color: Colors.cyan,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700),
                      ),
                      onTap: () => _openUserProfile(widget.post.user, context),
                    ),
                  ),
                  Text(readTimestamp(widget.post.created))
                ],
              ),
              subtitle: SpecialText(widget.post.comment),
              trailing: currentUser.id == widget.post.user.id
                  ? PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (String choice) async {
                        switch (choice) {
                          case 'Delete':
                            return showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text(
                                        'Are you sure you want to delete this ?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Yes'),
                                        onPressed: () {
                                          try {
                                            makeRequest(
                                                Request.DELETE,
                                                '/posts/comments/${widget.post.id}',
                                                {}).then((response) {
                                              print(response.body);
                                            });
                                          } catch (error) {
                                            print(error);
                                          }
                                          this.setState(() {
                                            deleted = true;
                                          });
                                          PostProvider.of(context).getPosts({});
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        final List<String> choices = ['Delete'];
                        return choices.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    )
                  : null,
            );
          },
        );
}
