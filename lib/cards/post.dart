import 'package:classroots/providers/auth.dart';
import 'package:classroots/screens/user_profile.dart';
import 'package:classroots/utils/api.dart';
import 'package:classroots/utils/intent.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:classroots/models/post.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/blocs/post.dart';
import 'package:classroots/providers/post.dart';
import 'package:classroots/utils/text.dart';
import 'package:flutter/gestures.dart';
import 'package:classroots/utils/time.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  PostCard(this.post);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked;
  int likeCount;
  PostBloc postBloc;
  UserModel currentUser;

  @override
  void initState() {
    super.initState();

    this.setState(() {
      likeCount = widget.post.likeCount;
      _isLiked = widget.post.likes.length > 0 ? true : false;
    });
  }

  void _openUserProfile(UserModel user) {
    // Navigator.of(context).pushNamed('/profile/user/${user.username}');
    openScreen(context, UserProfileScreen(user));
  }

  @override
  Widget build(BuildContext context) {
    postBloc = PostProvider.of(context);

    return StreamBuilder<UserModel>(
        stream: AuthProvider.of(context).currentUser,
        builder: (context, AsyncSnapshot<UserModel> currentUserSnapshot) {
          if (!currentUserSnapshot.hasData) return Container();
          currentUser = currentUserSnapshot.data;

          return ListTile(
            contentPadding: EdgeInsets.only(top: 8.0, left: 16.0, right: 8.0),
            leading: GestureDetector(
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.post.author.image),
                backgroundColor: Colors.grey,
              ),
              onTap: () {
                _openUserProfile(widget.post.author);
              },
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '@' + widget.post.author.username,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _openUserProfile(widget.post.author);
                              }),
                        // TextSpan(
                        //     text: ' on ',
                        //     style: DefaultTextStyle.of(context).style),
                        // TextSpan(
                        //     text:
                        //         '${widget.post.classInfo.name} (${widget.post.classInfo.code}) (${widget.post.section.name}, ${widget.post.section.number}) ')
                      ],
                      style: DefaultTextStyle.of(context).style.copyWith(
                          color: Colors.cyan,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Text(readTimestamp(widget.post.created).toLowerCase(),
                    style: TextStyle(color: Colors.grey)),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            subtitle: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(2.0),
                ),
                SpecialText(widget.post.description),
                widget.post.images != null
                    ? widget.post.images.length == 1
                        ? Container(
                            margin: EdgeInsets.only(top: 8.0),
                            height: 250.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        widget.post.images.elementAt(0)))),
                          )
                        : Container()
                    : Container(),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.reply,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/posts/comment/${widget.post.id}');
                      },
                    ),
                    Text('${widget.post.commentCount}'),
                    buildLikeButton(),
                    Text('$likeCount'),
                    Expanded(child: Container()),
                    currentUser.id != widget.post.author.id
                        ? Container()
                        : PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (String choice) async {
                              switch (choice) {
                                case 'Delete':
                                  return showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
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
                                                      '/posts/post/${widget.post.id}',
                                                      {}).then((response) {
                                                    print(response.body);
                                                    postBloc.getPosts({});
                                                  });
                                                } catch (error) {
                                                  print(error);
                                                }
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
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          );
        });
  }

  Widget buildLikeButton() => IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        postBloc.likePost(widget.post);
        this.setState(() {
          _isLiked = !_isLiked;
          if (_isLiked) {
            likeCount += 1;
          } else {
            likeCount -= 1;
          }
        });
        print('$_isLiked : $likeCount');
      });
}
