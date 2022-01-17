import 'package:flutter/material.dart';
import 'package:classroots/widgets/input.dart';
import 'package:classroots/widgets/spacing.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/blocs/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:classroots/forms/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _emailError;
  String _passwordError;

  bool _isLoading = false;
  ScaffoldState scaffoldState;

  _showError(error) {
    final snackBar = SnackBar(
      content: Text(error),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );

    if (scaffoldState != null) {
      scaffoldState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthProvider.of(context);
    scaffoldState = Scaffold.of(context);

    return Container(
      child: Center(
        child: _buildForm(authBloc),
      ),
      margin: EdgeInsets.only(top: 64.0, left: 32.0, right: 32.0),
    );
  }

  Widget _buildForm(AuthBloc authBloc) => Column(
        children: <Widget>[
          InputWidget(_emailController, 'email', false,
              TextInputType.emailAddress, _emailError),
          SpacingWidget(),
          InputWidget(_passwordController, 'password', true, TextInputType.text,
              _passwordError),
          SpacingWidget(),
          SpacingWidget(),
          GestureDetector(
            child: Text(
              _isLoading ? 'Creating Account...' : 'Create Account',
              style: TextStyle(color: Colors.purple[300], fontSize: 20.0),
            ),
            onTap: () async {
              if (_emailController.text.isEmpty ||
                  !Validator.isEmail(_emailController.text)) {
                this.setState(() => _emailError = 'Invalid email');
              } else if (_emailController.text.substring(
                      _emailController.text.length - 4,
                      _emailController.text.length) !=
                  '.edu') {
                this.setState(
                    () => _emailError = 'Only .edu emails are allowed');
              } else if (_passwordController.text.length < 5) {
                this.setState(() {
                  _emailError = null;
                  _passwordError = 'Invalid password';
                });
              } else {
                this.setState(() {
                  _emailError = null;
                  _passwordError = null;
                  _isLoading = true;
                });

                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text);
                } catch (error) {
                  if (error.message != null) {
                    _showError(error.message);
                  } else if (error.details != null) {
                    _showError(error.details);
                  } else {
                    _showError(error.toString());
                  }
                }

                this.setState(() {
                  _emailError = null;
                  _passwordError = null;
                  _isLoading = false;
                });
              }
            },
          ),
        ],
      );
}
