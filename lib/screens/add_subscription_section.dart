import 'dart:convert';

import 'package:classroots/models/class.dart';
import 'package:classroots/models/section.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/utils/api.dart';
import 'package:classroots/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddSubscriptionSectionScreen extends StatefulWidget {
  final ClassModel classInfo;
  AddSubscriptionSectionScreen(this.classInfo);

  @override
  _AddSubscriptionSectionScreenState createState() =>
      _AddSubscriptionSectionScreenState();
}

class _AddSubscriptionSectionScreenState
    extends State<AddSubscriptionSectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<String, SectionModel> sections = Map<String, SectionModel>();
  Map<String, bool> subscribed = Map<String, bool>();
  Map<String, bool> deleted = Map<String, bool>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.classInfo.name} (${widget.classInfo.code})'),
        elevation: 0.05,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              return showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController _sectionController =
                      TextEditingController();
                  String _error;
                  return AlertDialog(
                    title: Text('Add Section (3 Digit)'),
                    content: InputWidget(
                      _sectionController,
                      'Please provide section number',
                      false,
                      TextInputType.number,
                      _error,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Add'),
                        onPressed: () {
                          if (_sectionController.text.isNotEmpty) {
                            try {
                              if (int.parse(_sectionController.text) < 999) {
                                makeRequest(Request.POST,
                                    '/profile/section/${widget.classInfo.id}', {
                                  'number': int.parse(_sectionController.text)
                                }).then((response) {
                                  print(response.body);
                                  try {
                                    final body = jsonDecode(response.body);
                                    print(
                                        'Status: ${response.statusCode}, body: ${response.body}');
                                    if (response.statusCode == 200) {
                                      if (body['error']) {
                                        _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text(body['result']),
                                            action: SnackBarAction(
                                              label: 'Close',
                                              onPressed: () {},
                                            ),
                                          ),
                                        );
                                      } else {
                                        SectionModel section =
                                            SectionModel.fromJson(
                                                body['result']);
                                        this.setState(() {
                                          sections
                                              .addAll({section.id: section});
                                        });
                                      }
                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(body['result']),
                                          action: SnackBarAction(
                                            label: 'Close',
                                            onPressed: () {},
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    print(error);
                                  }
                                });
                                Navigator.of(context).pop();
                              }
                            } catch (error) {
                              print(error);
                            }
                          }
                        },
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future:
            makeRequest(Request.GET, '/sections/${widget.classInfo.id}', null),
        builder: (BuildContext context,
            AsyncSnapshot<http.Response> sectionsSnapshot) {
          if (!sectionsSnapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (sectionsSnapshot.hasError)
            return Center(child: Text('An Error Occurred'));

          final http.Response response = sectionsSnapshot.data;
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            body['result'].forEach((result) {
              SectionModel section = SectionModel.fromJson(result);
              sections.addAll({section.id: section});
            });

            return ListView.builder(
              itemCount: sections.length,
              itemBuilder: (BuildContext context, int index) {
                SectionModel section = sections.values.toList()[index];

                return FutureBuilder(
                  future: makeRequest(Request.GET,
                      '/profile/subscriptions/${section.id}', null),
                  builder: (BuildContext context,
                      AsyncSnapshot<http.Response> sectionSnapshot) {
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
                      if (!deleted.containsKey(section.id)) {
                        deleted.addAll({section.id: body['result']});
                      }
                      // if (isSubscribed == null) {
                      //   isSubscribed = body['result'];
                      // }
                      return StreamBuilder<UserModel>(
                          stream: AuthProvider.of(context).currentUser,
                          builder:
                              (context, AsyncSnapshot<UserModel> snapshot) {
                            if (!snapshot.hasData) return Container();
                            return ListTile(
                              // title: Text(section.name),
                              title: Text('Section number: ${section.number}'),
                              trailing: Icon(
                                Icons.check_circle,
                                color: deleted[section.id] ? Colors.blue : null,
                              ),
                              onTap: () {
                                this.setState(
                                  () {
                                    deleted.updateAll(
                                      (
                                        String key,
                                        bool value,
                                      ) =>
                                          key != section.id ? false : !value,
                                    );
                                  },
                                );
                                try {
                                  makeRequest(
                                    Request.POST,
                                    '/profile/subscriptions',
                                    {
                                      'section': section.id,
                                    },
                                  ).then((response) {
                                    AuthProvider.of(context).createProfile(
                                        snapshot.data.image,
                                        snapshot.data.username,
                                        snapshot.data.name,
                                        snapshot.data.sex,
                                        snapshot.data.dob,
                                        snapshot.data.section);
                                    print(response.body);
                                  });
                                } catch (error) {
                                  print(error);
                                }
                              },
                            );
                          });
                    } else {
                      return ListTile(
                        // title: Text(section.name),
                        title: Text('Section number: ${section.number}'),
                      );
                    }
                  },
                );
              },
            );
          } else {
            return Center(child: Text('An Error Occurred'));
          }
        },
      ),
    );
  }
}
