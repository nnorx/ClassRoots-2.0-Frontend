import 'package:flutter/material.dart';
import 'package:classroots/cards/post.dart';
import 'package:classroots/providers/post.dart';
import 'package:classroots/blocs/post.dart';
import 'package:classroots/models/post.dart';
import 'package:classroots/blocs/auth.dart';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  PostBloc postBloc;
  AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    postBloc = PostProvider.of(context);

    postBloc.getPosts(Map<String, PostModel>());
    return Container(
      margin: EdgeInsets.only(top: 2.0),
      child: Column(
        children: <Widget>[
          // buildSearchBar(),
          Expanded(child: buildList())
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 4.0,
            )
          ]),
    );
  }

  Widget buildSearchBar() => Container(
        margin: EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
        ),
      );

  Widget buildInput() => Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Send a message',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(16.0))));

  Widget buildList() => StreamBuilder(
        stream: postBloc.posts,
        builder: (context, AsyncSnapshot<Map<String, PostModel>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data.length == 0) {
            return Center(child: Text('No Posts Found'));
          }

          return ListView.builder(
            itemCount: snapshot.data.values.length,
            itemBuilder: (context, index) =>
                PostCard(snapshot.data.values.toList()[index]),
          );
        },
      );
}
