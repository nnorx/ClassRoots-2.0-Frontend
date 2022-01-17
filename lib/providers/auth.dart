import 'package:flutter/material.dart'
    show InheritedWidget, Key, Widget, BuildContext;
import 'package:classroots/blocs/auth.dart';

class AuthProvider extends InheritedWidget {
  final authBloc = AuthBloc();

  AuthProvider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AuthBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AuthProvider) as AuthProvider)
        .authBloc;
  }
}
