import 'package:flutter/material.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/providers/post.dart';
import 'package:classroots/screens/home.dart';
import 'package:classroots/screens/profile.dart';
import 'package:classroots/screens/create_profile.dart';
import 'package:classroots/screens/post_create.dart';
import 'package:classroots/screens/post_tagged.dart';
import 'package:classroots/screens/post_comment.dart';
import 'package:classroots/screens/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    try {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) => PostProvider(
        child: AuthProvider(
          child: MaterialApp(
            title: 'ClassRoots',
            onGenerateRoute: routes,
            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: Colors.white,
              accentColor: Color.fromRGBO(29, 233, 182, 1.0),
              fontFamily: 'Raleway',
            ),
            debugShowCheckedModeBanner: false,
          ),
        ),
      );

  Route routes(RouteSettings routeSettings) {
    Widget screen;
    String route = routeSettings.name;

    if (route == '/') {
      screen = HomeScreen();
    }

    if (route == '/profile') {
      screen = ProfileScreen();
    }

    if (route == '/profile/edit') {
      screen = CreateProfileScreen('Edit Profile');
    }

    // if (route.contains('/profile/user/')) {
    //   String username = route.replaceAll('/profile/user/', '');
    //   screen = UserProfileScreen(username);
    // }

    if (route == '/posts/create') {
      screen = PostCreateScreen();
    }

    if (route.contains('/posts/tagged/')) {
      screen = PostTaggedScreen(route.replaceAll('/posts/tagged/', ''));
    }

    if (route.contains('/posts/comment/')) {
      screen = PostCommentScreen(route.replaceAll('/posts/comment/', ''));
    }

    return MaterialPageRoute(builder: (context) => screen);
  }
}
