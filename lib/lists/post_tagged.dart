import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:classroots/utils/api.dart';
import 'package:classroots/cards/post.dart';
import 'package:classroots/models/post.dart';

class PostTaggedList extends StatelessWidget {
  final String tag;
  final List<PostModel> posts = [];

  PostTaggedList(this.tag);

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: getPostTagged(tag),
        builder: (context, AsyncSnapshot<Response> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          if (snapshot.hasError)
            return Center(
              child: Text(snapshot.error.toString()),
            );

          try {
            final Response response = snapshot.data;
            if (response.statusCode != 200)
              return Center(
                child: Text('An error occured'),
              );

            final body = jsonDecode(response.body);
            if (body['error']) {
              return Center(child: Text(body['result']));
            }
            List<dynamic> result = body['result'];
            result.forEach((item) {
              posts.add(PostModel.fromJson(item));
            });

            if (result.length == 0) {
              return Center(child: Text('No Posts Found'));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(posts[index]),
            );
          } catch (error) {
            return Center(child: Text(error.toString()));
          }
        },
      );
}
