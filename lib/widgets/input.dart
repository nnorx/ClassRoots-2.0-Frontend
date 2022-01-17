import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController _controller;
  final String _hint;
  final String _error;
  final bool _isObsureText;
  final TextInputType _keyboardType;

  InputWidget(
    this._controller,
    this._hint,
    this._isObsureText,
    this._keyboardType,
    this._error,
  );

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        decoration: InputDecoration(
            hintText: _hint,
            errorText: _error,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black))),
        obscureText: _isObsureText,
        keyboardType: _keyboardType,
      );
}
