import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:classroots/models/post.dart';
import 'package:classroots/utils/api.dart' as ApiUtil;
import 'package:http/http.dart' show Response;
import 'dart:convert' show jsonDecode, jsonEncode;

class PostBloc extends Object {
  final _posts = BehaviorSubject<Map<String, PostModel>>();

  // Retrieve data from Stream
  Stream<Map<String, PostModel>> get posts => _posts.stream;
  // Add data to Stream
  Function(Map<String, PostModel>) get changePosts => _posts.sink.add;

  Future<String> createPost(
      String description, List<String> images, String section) async {
    try {
      final Response response =
          await ApiUtil.createPost(description, images, section);
      print(response.body);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        bool error = body['error'];
        if (!error) {
          await getPosts(Map<String, PostModel>());
          return null;
        } else {
          return body['result']
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '\n');
        }
      } else {
        return 'An error occured, please try again';
      }
    } catch (error) {
      return 'An error occured, please try again';
    }
  }

  getPosts(Map<String, PostModel> currentList) async {
    try {
      final Response response = await ApiUtil.getPosts();
      if (response.statusCode == 200) {
        _posts.addError(null);
        final body = jsonDecode(response.body);
        bool error = body['error'];
        if (!error) {
          List<dynamic> results = body['result'];
          results.forEach((result) {
            PostModel post = PostModel.fromJson(result);
            if (currentList.containsKey(post.id)) {
              currentList.update(post.id, (PostModel post) => post);
            } else {
              currentList.addAll({post.id: post});
            }
          });
          changePosts(currentList);
        }
      } else {}
    } catch (error) {
      _posts.addError(error.message);
    }
  }

  likePost(PostModel post) async {
    try {
      final Response response = await ApiUtil.getLikePost(post.id);
      if (response.statusCode != 200) {
        print(response);
      }
    } catch (error) {
      print(error);
    }
  }
}
