import 'package:flutter/material.dart';
import 'package:classroots/forms/login.dart';
import 'package:classroots/forms/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          children: <Widget>[
            Container(
              child: Image.asset('images/logo.png'),
              margin: EdgeInsets.only(top: 32.0, left: 64.0, right: 64.0),
            ),
            _currentTab == 0 ? LoginForm() : RegisterForm(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: FlatButton(
            child: Text(
              _currentTab == 0
                  ? 'No account yet ? Create one.'
                  : 'Already have an acccount ? Sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.0, color: Colors.blue),
            ),
            onPressed: () =>
                this.setState(() => _currentTab = _currentTab == 0 ? 1 : 0),
          ),
        ),
      );
}
