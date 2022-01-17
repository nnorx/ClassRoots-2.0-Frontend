import 'dart:async';

import 'package:classroots/widgets/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/blocs/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/screens/create_profile.dart';
import 'package:classroots/screens/login.dart';
import 'package:classroots/screens/splash.dart';
import 'package:classroots/lists/post.dart';
import 'package:classroots/screens/profile.dart';
import 'package:flutter/services.dart';

const Duration _kFrontLayerSwitchDuration = Duration(milliseconds: 300);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key key,
    this.testMode = false,
    this.optionsPage,
  }) : super(key: key);

  final Widget optionsPage;
  final bool testMode;

  // In checked mode our MaterialApp will show the default "debug" banner.
  // Otherwise show the "preview" banner.
  static bool showPreviewBanner = true;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey appBarKey = GlobalKey();
  Offset position;

  AnimationController _controller;
  bool _isMenuOpen = false;

  static Widget _topHomeLayout(
      Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    if (currentChild != null) children = children.toList()..add(currentChild);
    return Stack(
      children: children,
      alignment: Alignment.topCenter,
    );
  }

  static const AnimatedSwitcherLayoutBuilder _centerHomeLayout =
      AnimatedSwitcher.defaultLayoutBuilder;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        debugLabel: 'preview banner',
        vsync: this)
      ..forward();
  }

  _checkCurrentUser() async {
    _currentUser = await _auth.currentUser();
    _currentUser?.getIdToken(refresh: true);

    _auth.onAuthStateChanged.listen((FirebaseUser user) async {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _isLoading
      ? SplashScreen()
      : _currentUser == null ? LoginScreen() : _buildBody();

  Widget _buildBody() {
    final AuthBloc authBloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: authBloc.loggedIn,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          authBloc.getAuthData();
          authBloc.loginUser(_currentUser);
          return SplashScreen();
        }

        if (!snapshot.data) {
          authBloc.loginUser(_currentUser);
          return Scaffold(
            body: Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Container(
                    margin: EdgeInsets.all(16.0),
                  ),
                  Text('Logging In ....'),
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          );
        }

        return _buildLanding(authBloc);
      },
    );
  }

  Widget _buildLanding(AuthBloc authBloc) => StreamBuilder(
        stream: authBloc.currentUser,
        builder: (context, AsyncSnapshot<UserModel> userSnapshot) {
          if (!userSnapshot.hasData) return SplashScreen();

          if (!userSnapshot.data.profileCreated)
            return CreateProfileScreen('Create Profile');

          return _buildHome(userSnapshot.data);
        },
      );

  Widget _buildHome(UserModel user) {
    /* Animation properties for drawer open close icon */
    const Curve switchOutCurve =
        Interval(0.4, 1.0, curve: Curves.fastOutSlowIn);
    const Curve switchInCurve = Interval(0.4, 1.0, curve: Curves.fastOutSlowIn);

    Widget home = Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () {
            // Pop the category page if Android back button is pressed.
            if (_isMenuOpen == false) {
              setState(() => _isMenuOpen = true);
              return Future<bool>.value(false);
            }
            setState(() => _isMenuOpen = false);
            return Future<bool>.value(true);
          },
          child: Backdrop(
            backTitle: Container(
              child: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
            backLayer: ProfileScreen(),
            frontAction: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              switchOutCurve: switchOutCurve,
              switchInCurve: switchInCurve,
              child: CircleAvatar(
                radius: 22.0,
                child: CircleAvatar(
                  child: buildUserImage(user),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: Colors.white,
              ), // leading Menu icon
            ),
            frontTitle: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 12.0),
                    child: Image.asset(
                      'images/logo.png',
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '/ ${user.classInfo.name}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                ],
              ),
            ),
            frontHeading: widget.testMode ? null : Container(height: 24.0),
            frontLayer: AnimatedSwitcher(
                duration: _kFrontLayerSwitchDuration,
                switchOutCurve: switchOutCurve,
                switchInCurve: switchInCurve,
                layoutBuilder: _topHomeLayout,
                child: _isMenuOpen == false ? PostList() : ProfileScreen()),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pushNamed('/posts/create');
        },
        backgroundColor: Theme.of(context).accentColor,
      ),
    );

    assert(() {
      HomeScreen.showPreviewBanner = false;
      return true;
    }());

    if (HomeScreen.showPreviewBanner) {
      home = Stack(fit: StackFit.expand, children: <Widget>[
        home,
        FadeTransition(
            opacity:
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            child: const Banner(
              message: 'PREVIEW',
              location: BannerLocation.topEnd,
            )),
      ]);
    }
    home = AnnotatedRegion<SystemUiOverlayStyle>(
        child: home, value: SystemUiOverlayStyle.light);

    return Theme(
      data: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Raleway',
          accentColor: Theme.of(context).accentColor),
      child: home,
    );
  }

  Widget buildUserImage(UserModel user) => CircleAvatar(
        backgroundImage: NetworkImage(user.image),
        radius: ((position == null ? 100.0 : position.dy)) / 3.5,
      );
}
