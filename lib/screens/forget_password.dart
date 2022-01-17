import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classroots/widgets/input.dart';
import 'package:classroots/widgets/spacing.dart';
import 'package:classroots/forms/validator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String _error;
  String _response;
  ScaffoldState scaffoldState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ListTile(
            title: InputWidget(_emailController, 'Enter your email', false,
                TextInputType.emailAddress, _error),
          ),
          SpacingWidget(),
          FlatButton(
            onPressed: () async {
              if (_emailController.text.isEmpty ||
                  !Validator.isEmail(_emailController.text)) {
                this.setState(() => _error = 'Invalid email');
              } else {
                this.setState(() => _error = null);

                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: _emailController.text);
                  this.setState(() => _response =
                      'Please check your email, ${_emailController.text} to reset password');
                } catch (error) {
                  this.setState(() => _response = error.details);
                }
              }
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            color: Theme.of(context).accentColor,
            child: Text(
              'Reset Password',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w100),
            ),
          ),
          ListTile(
            title: Text(_response == null ? '' : _response,
                style: TextStyle(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}
