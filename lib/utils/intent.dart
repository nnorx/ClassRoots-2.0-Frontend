import 'package:flutter/material.dart';

openScreen(context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
