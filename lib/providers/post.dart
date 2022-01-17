import 'package:flutter/material.dart'
    show InheritedWidget, Key, Widget, BuildContext;
import 'package:classroots/blocs/post.dart';

class PostProvider extends InheritedWidget {
  final postBloc = PostBloc();

  PostProvider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static PostBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PostProvider) as PostProvider)
        .postBloc;
  }
}
