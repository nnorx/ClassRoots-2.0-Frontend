import 'dart:convert';
import 'dart:io';

import 'package:classroots/models/section.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:classroots/providers/post.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:classroots/utils/image.dart';
import 'package:http/http.dart' as http;

class PostCreateScreen extends StatefulWidget {
  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _descriptionError;
  bool _creatingPost = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserModel currentUser;
  Map<String, SectionModel> sections = Map<String, SectionModel>();
  String selectedSection;

  ImageSource _imageSource;
  File _image;

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
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future getImage() async {
    final image =
        await ImagePicker.pickImage(source: _imageSource, maxWidth: 720.0);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: AuthProvider.of(context).currentUser,
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
          if (!snapshot.hasData) return Scaffold();

          currentUser = snapshot.data;

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Post to ${currentUser.classInfo.name}'),
              elevation: 0.0,
            ),
            body: FutureBuilder(
              future: makeRequest(
                  Request.GET, '/sections/${currentUser.classInfo.id}', null),
              builder: (BuildContext context,
                  AsyncSnapshot<http.Response> sectionsSnapshot) {
                if (!sectionsSnapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                if (sectionsSnapshot.hasError)
                  return Center(child: Text('An Error Occurred'));

                if (sectionsSnapshot.data.statusCode == 200) {
                  final body = jsonDecode(sectionsSnapshot.data.body);
                  body['result'].forEach((result) {
                    SectionModel section = SectionModel.fromJson(result);
                    sections.addAll({section.id: section});
                  });

                  return ListView(
                    children: <Widget>[
                      buildAddDescription(),
                      // ListTile(
                      //   title: Row(
                      //     children: <Widget>[
                      //       Expanded(child: Text('Section')),
                      //       DropdownButton(
                      //         items: sections.values.toList().map((value) {
                      //           return DropdownMenuItem<String>(
                      //             value: value.id,
                      //             child: Text(value.name),
                      //           );
                      //         }).toList(),
                      //         hint: selectedSection != null
                      //             ? Text(sections[selectedSection] != null
                      //                 ? sections[selectedSection].name
                      //                 : 'Select Section')
                      //             : Text('Select Section'),
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedSection = value;
                      //           });
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      buildFunctions(),
                      _image == null ? Container() : Image.file(_image)
                    ],
                  );
                } else {
                  return Center(child: Text('An Error Occurred'));
                }
              },
            ),
          );
        },
      );

  Widget buildAddDescription() => Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: TextField(
          controller: _descriptionController,
          maxLength: 260,
          maxLines: 3,
          decoration: InputDecoration(
              hintText: 'Message ...',
              errorText: _descriptionError,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent))),
        ),
        margin: EdgeInsets.only(left: 8.0, right: 8.0),
      );

  Widget buildFunctions() => Row(
        children: <Widget>[
          RaisedButton.icon(
            color: Colors.white,
            icon: Icon(
              FontAwesomeIcons.camera,
              color: Colors.black,
            ),
            label: Text(
              'Camera',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _imageSource = ImageSource.camera;
              getImage();
            },
          ),
          RaisedButton.icon(
            color: Colors.white,
            icon: Icon(
              FontAwesomeIcons.image,
              color: Colors.black,
            ),
            label: Text(
              'Gallery',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _imageSource = ImageSource.gallery;
              getImage();
            },
          ),
          buildSubmitButton()
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      );

  Widget buildSubmitButton() => MaterialButton(
        color: Theme.of(context).accentColor,
        child: Text(
          _creatingPost ? 'Publishing' : 'Publish Post',
          style: TextStyle(
              fontSize: 17.0,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          if (_descriptionController.text.isEmpty) {
            this.setState(() => _descriptionError = 'Message is empty');
          } else if (!_creatingPost) {
            print('pressed');
            this.setState(() {
              _descriptionError = null;
              _creatingPost = true;
            });
            List<String> images = [];
            if (_image != null) {
              images.add(await uploadImage(_image));
            }
            String error = await PostProvider.of(context).createPost(
                _descriptionController.text, images, currentUser.section);
            if (error == null) {
              this.setState(() {
                _creatingPost = false;
                _descriptionController.text = '';
              });
              Navigator.of(context).pop();
            } else {
              this.setState(() {
                _creatingPost = false;
              });
              _showError(error.trim());
            }
          }
        },
      );
}
