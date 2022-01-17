import 'package:classroots/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:classroots/models/section.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SectionCard extends StatefulWidget {
  final SectionModel section;
  SectionCard(this.section);
  @override
  _SectionCardState createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool isSubscribed;
  SectionModel section;

  @override
  Widget build(BuildContext context) {
    section = widget.section;

    return FutureBuilder(
      future: makeRequest(
          Request.GET, '/profile/subscriptions/${section.id}', null),
      builder:
          (BuildContext context, AsyncSnapshot<http.Response> sectionSnapshot) {
        if (!sectionSnapshot.hasData)
          return ListTile(
            // title: Text(section.name),
            title: Text('Section number: ${section.number}'),
            trailing: Text('Please Wait ...'),
          );
        if (sectionSnapshot.hasError)
          return ListTile(
            // title: Text(section.name),
            title: Text('Section number: ${section.number}'),
            trailing: Text('Please Wait ...'),
          );

        final http.Response response = sectionSnapshot.data;
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (isSubscribed == null) {
            isSubscribed = body['result'];
          }
          return ListTile(
            // title: Text(section.name),
            title: Text('Section number: ${section.number}'),
            trailing: Icon(
              Icons.check_circle,
              color: isSubscribed ? Colors.blue : null,
            ),
            onTap: () {
              this.setState(() {
                isSubscribed = !isSubscribed;
              });
              try {
                makeRequest(
                  Request.POST,
                  '/profile/subscriptions',
                  {
                    'section': section.id,
                  },
                );
              } catch (error) {
                print(error);
              }
            },
          );
        } else {
          return ListTile(
            // title: Text(section.name),
            title: Text('Section number: ${section.number}'),
          );
        }
      },
    );
  }
}
