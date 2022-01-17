import 'dart:convert';

import 'package:classroots/models/class.dart';
import 'package:classroots/models/subscription.dart';
import 'package:classroots/providers/post.dart';
import 'package:classroots/screens/add_subscription_section.dart';
import 'package:flutter/material.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/blocs/auth.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/screens/add_subscription.dart';
import 'package:classroots/utils/intent.dart';
import 'package:http/http.dart';
import 'package:classroots/utils/api.dart' as api;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AuthBloc authBloc;
  Map<String, SubscriptionModel> _subscriptions =
      Map<String, SubscriptionModel>();
  Map<String, ClassModel> _subscribedClasses = Map<String, ClassModel>();

  UserModel currentUser;

  @override
  void initState() {
    super.initState();

    _fetchSubscribedClasses();
  }

  Future<void> _fetchSubscribedClasses() async {
    try {
      final Response response = await api.getSubscriptions();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        bool _error = body['error'];

        if (!_error) {
          Map<String, SubscriptionModel> subscriptions =
              Map<String, SubscriptionModel>();

          final List<dynamic> _result = body['result'];
          _result.forEach((result) {
            SubscriptionModel subscriptionModel =
                SubscriptionModel.fromJson(result);
            if (subscriptions.containsKey(subscriptionModel.id)) {
              subscriptions.update(subscriptionModel.id,
                  (SubscriptionModel previousSubscriptionModel) {
                return subscriptionModel;
              });
            } else {
              subscriptions.addAll({subscriptionModel.id: subscriptionModel});
            }
          });
          this.setState(() {
            _subscriptions = subscriptions;
          });
        } else {
          _showError(body['result'].toString());
        }
      } else {
        _showError('An error occured');
      }
    } catch (error) {
      print(error);
    }
  }

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
  Widget build(BuildContext context) {
    authBloc = AuthProvider.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).accentColor,
      body: StreamBuilder(
        stream: authBloc.currentUser,
        builder: (BuildContext context,
            AsyncSnapshot<UserModel> currentUserSnapshot) {
          if (!currentUserSnapshot.hasData) return Container();
          currentUser = currentUserSnapshot.data;

          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 12.0),
                child: ListTile(
                  leading: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  title: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Course Code (e.g. POMS.2010)',
                        style: TextStyle(color: Colors.white)),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    onSelected: (String choice) async {
                      switch (choice) {
                        case 'Edit Profile':
                          Navigator.of(context).pushNamed('/profile/edit');
                          break;
                        case 'Logout':
                          authBloc.logout();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      final List<String> choices = ['Edit Profile', 'Logout'];
                      return choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${choice[0].toUpperCase()}${choice.substring(1)}',
                                ),
                              ),
                              choice == 'Logout'
                                  ? Icon(Icons.power_settings_new)
                                  : Icon(Icons.edit)
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                  onTap: () {
                    openScreen(
                        context, AddSubscription(_fetchSubscribedClasses));
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: api.getClasses(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Response> snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());

                    try {
                      if (snapshot.data.statusCode == 200) {
                        final body = jsonDecode(snapshot.data.body);
                        bool _error = body['error'];

                        if (!_error) {
                          final _result = body['result'];

                          _subscribedClasses.clear();

                          _subscribedClasses.addAll({
                            currentUser.classInfo.id: currentUser.classInfo
                          });

                          _result.forEach((result) {
                            final ClassModel classModel =
                                ClassModel.fromJson(result);
                            _subscribedClasses
                                .addAll({classModel.id: classModel});
                          });

                          return ListView.separated(
                            itemCount: _subscribedClasses.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == _subscribedClasses.length)
                                return SizedBox(height: 125.0);

                              final ClassModel classModel =
                                  _subscribedClasses.values.toList()[index];

                              return ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '${classModel.name} (${classModel.code})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    currentUser.classInfo.id == classModel.id
                                        ? Container()
                                        : OutlineButton(
                                            color:
                                                Theme.of(context).accentColor,
                                            child: Text(
                                              'UnSubscribe',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            onPressed: () {
                                              try {
                                                api.makeRequest(
                                                  api.Request.POST,
                                                  '/profile/unsubscribe/${classModel.id}',
                                                  {},
                                                ).then((response) {
                                                  print(response.body);
                                                  PostProvider.of(context)
                                                      .getPosts({});
                                                });
                                              } catch (error) {
                                                print(error);
                                              }

                                              try {
                                                authBloc
                                                    .createProfile(
                                                  currentUser.image,
                                                  currentUser.username,
                                                  currentUser.name,
                                                  currentUser.sex,
                                                  currentUser.dob,
                                                  currentUser.section,
                                                )
                                                    .then((response) {
                                                  PostProvider.of(context)
                                                      .getPosts({});
                                                });
                                              } catch (error) {
                                                print(error);
                                              }

                                              // openScreen(
                                              //     context,
                                              //     AddSubscriptionSectionScreen(
                                              //         classModel));
                                            },
                                          )
                                  ],
                                ),
                                subtitle:
                                    currentUser.classInfo.id == classModel.id
                                        ? Text(
                                            'Current Class',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                onTap: currentUser.classInfo.id == classModel.id
                                    ? null
                                    : () {
                                        authBloc.updateClass(classModel.id);
                                      },
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(
                                      color: Colors.white,
                                    ),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    } catch (error) {
                      return Container();
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildUser() => StreamBuilder(
        stream: authBloc.currentUser,
        builder: (context, AsyncSnapshot<UserModel> userSnapshot) {
          if (!userSnapshot.hasData) return Container();

          UserModel user = userSnapshot.data;
          return ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.image),
                  radius: 40.0,
                ),
                title: Text(
                  user.name,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  children: <Widget>[
                    Container(margin: EdgeInsets.all(4.0)),
                    Text(
                        '${user.classInfo.university.name} (${user.classInfo.university.code})'),
                    Container(margin: EdgeInsets.all(4.0)),
                    Text('${user.classInfo.name} (${user.classInfo.code})'),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              Container(margin: EdgeInsets.all(10.0)),
              ListTile(
                title: Text('About me\n'),
                subtitle: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce imperdiet tellus sit amet eleifend ultricies. Donec ut ultricies leo. Maecenas sagittis augue vel volutpat condimentum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In blandit cursus tellus vel hendrerit. Maecenas at ipsum sed tellus rhoncus bibendum. Donec quis fringilla odio.'),
              ),
            ],
          );
        },
      );

  Widget buildUserImage(UserModel user) => CircleAvatar(
        backgroundImage: NetworkImage(user.image),
      );
}
