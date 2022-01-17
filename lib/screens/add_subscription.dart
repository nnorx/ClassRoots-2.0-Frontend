import 'dart:convert';

import 'package:classroots/models/user.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/screens/add_subscription_section.dart';
import 'package:flutter/material.dart';
import 'package:classroots/utils/api.dart';
import 'package:http/http.dart';
import 'package:classroots/models/class.dart';
import 'package:classroots/blocs/post.dart';

class AddSubscription extends StatefulWidget {
  final Function callBack;
  AddSubscription(this.callBack);
  @override
  _AddSubscriptionState createState() => _AddSubscriptionState();
}

class _AddSubscriptionState extends State<AddSubscription> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<dynamic> _result = [];
  UserModel currentUser;

  _showError(error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(error),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Select Class'),
          elevation: 0.05,
        ),
        body: StreamBuilder<UserModel>(
            stream: AuthProvider.of(context).currentUser,
            builder: (context, AsyncSnapshot<UserModel> currentUserSnapshot) {
              if (!currentUserSnapshot.hasData) return Container();
              currentUser = currentUserSnapshot.data;

              return FutureBuilder(
                future:
                    getClassesByUniversity(currentUser.classInfo.university.id),
                builder:
                    (BuildContext context, AsyncSnapshot<Response> snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: Text('Please Wait ...'));

                  if (snapshot.data.statusCode == 200) {
                    final body = jsonDecode(snapshot.data.body);
                    bool _error = body['error'];

                    if (!_error) {
                      _result = body['result'];
                      return ListView.builder(
                          itemCount: _result.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ClassModel classModel =
                                ClassModel.fromJson(_result[index]);

                            return ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${classModel.name} (${classModel.code})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Subscribe',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddSubscriptionSectionScreen(
                                            classModel),
                                  ),
                                );
                              },
                            );
                          });
                    } else {
                      return Center(child: Text('An error occured'));
                    }
                  } else {
                    return Center(child: Text('An error occured'));
                  }
                },
              );
            }),
      );
}
