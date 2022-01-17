import 'package:flutter/material.dart';
import 'package:classroots/lists/post_tagged.dart';

class PostTaggedScreen extends StatefulWidget {
  final String tag;

  PostTaggedScreen(this.tag);

  @override
  _PostTaggedScreenState createState() => _PostTaggedScreenState();
}

class _PostTaggedScreenState extends State<PostTaggedScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(widget.tag),
        ),
        body: PostTaggedList(widget.tag.replaceFirst('#', '')),
      );
}
