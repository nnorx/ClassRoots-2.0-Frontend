import 'package:flutter/material.dart';
import 'package:classroots/utils/api.dart';
import 'package:http/http.dart' show Response;
import 'package:classroots/models/post_comment.dart';
import 'dart:convert';
import 'package:classroots/cards/post_comment.dart';
import 'package:classroots/blocs/auth.dart';
import 'package:classroots/providers/auth.dart';

class PostCommentScreen extends StatefulWidget {
  final String post;

  PostCommentScreen(this.post);

  @override
  _PostCommentScreenState createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  List<PostCommentModel> comments = [];
  List<String> previousIds = [];
  bool loading = true;

  final commentController = TextEditingController();
  String commentError;
  AuthBloc authProvider;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  _addComment(String comment) async {
    try {
      final Response response =
          await postComment(widget.post, commentController.text);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print(body);
        if (!body['error']) {
          this.setState(() {
            comments.insert(0, PostCommentModel.fromJson(body['result']));
          });
        }
      }
    } catch (error) {
      this.setState(() {
        commentError = error.toString();
      });
    }
  }

  _fetchComments() async {
    try {
      final Response response = await getPostComment(widget.post);
      if (response.statusCode == 200) {
        this.setState(() {
          loading = false;
        });
        final body = jsonDecode(response.body);
        bool error = body['error'];
        if (!error) {
          body['result'].forEach((result) {
            PostCommentModel commentModel = PostCommentModel.fromJson(result);
            if (!previousIds.contains(commentModel.id)) {
              previousIds.add(commentModel.id);
              this.setState(() {
                comments.add(commentModel);
              });
            }
          });
        } else {
          print(body['result']);
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = AuthProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : _buildList(),
          ),
          _buildAddComment()
        ],
      ),
    );
  }

  _buildList() => ListView.builder(
        reverse: true,
        itemCount: comments.length,
        itemBuilder: (context, index) => PostCommentCard(comments[index]),
      );

  _buildAddComment() => ListTile(
        title: TextField(
          maxLines: 1,
          maxLength: 260,
          controller: commentController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12.0),
            hintText: 'Reply ...',
            errorText: commentError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Theme.of(context).accentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Theme.of(context).accentColor),
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (commentController.text.isEmpty) {
              this.setState(() {
                commentError = 'Reply cannot be empty';
              });
            } else if (commentController.text.length > 260) {
              this.setState(() {
                commentError = 'Max length of reply is 260 charactors';
              });
            } else {
              _addComment(commentController.text);
              this.setState(() {
                commentError = null;
                commentController.text = '';
              });
            }
          },
        ),
      );
}
