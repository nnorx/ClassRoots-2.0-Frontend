import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SpecialText extends StatelessWidget {
  final String text;

  SpecialText(this.text);

  @override
  Widget build(BuildContext context) {
    List<String> _text = text.split(' ');
    List<TextSpan> seperatedHashTags = _text
        .map((String word) => word.startsWith('#')
            ? TextSpan(
                text: '$word ',
                style:
                    TextStyle(color: Colors.cyan, fontWeight: FontWeight.w700),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).pushNamed('/posts/tagged/$word');
                  })
            : TextSpan(text: '$word ', style: TextStyle(color: Colors.black)))
        .toList();
    return RichText(
        text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: seperatedHashTags));
  }
}
