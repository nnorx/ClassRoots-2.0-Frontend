import 'package:flutter/material.dart';
import 'package:classroots/models/user.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  UserCard(this.user);

  @override
  Widget build(BuildContext context) => Container(
        child: buildUser(),
        color: Theme.of(context).accentColor,
      );

  Widget buildUser() => ListTile(
        contentPadding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(user.image),
              backgroundColor: Colors.grey,
              radius: 20.0 * 1.5,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Column(
                      children: <Widget>[
                        Text(
                          user.postCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(margin: EdgeInsets.all(2.0)),
                        Text(
                          'post',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: Column(
                      children: <Widget>[
                        Text(
                          user.followingCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(margin: EdgeInsets.all(2.0)),
                        Text(
                          'following',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: Column(
                      children: <Widget>[
                        Text(
                          user.followersCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(margin: EdgeInsets.all(2.0)),
                        Text(
                          'followers',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {},
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            )
          ],
        ),
        subtitle: ListTile(
          contentPadding: EdgeInsets.all(0.0),
          title: Text(
            user.name,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'University of Massachusetts',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}
