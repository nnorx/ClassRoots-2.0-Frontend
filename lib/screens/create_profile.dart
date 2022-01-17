import 'package:classroots/models/section.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:classroots/providers/auth.dart';
import 'package:classroots/utils/api.dart';
import 'package:classroots/models/user.dart';
import 'package:classroots/models/university.dart';
import 'package:classroots/models/class.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' show Response;
import 'package:classroots/utils/image.dart';

class CreateProfileScreen extends StatefulWidget {
  final String title;

  CreateProfileScreen(this.title);

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  int _selectedGender;
  DateTime _dateOfBirth;
  UserModel currentUser;

  ImageSource _imageSource;
  File _image;
  String _downloadImageUrl;
  String selectedUniversity;
  String selectedClass;
  String selectedSection;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScaffoldState scaffoldState;
  bool _savingProfile = false;

  _showError(error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(error),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    ));
  }

  _setLoading(bool loading) => this.setState(() => _savingProfile = loading);

  Future getImage() async {
    final image =
        await ImagePicker.pickImage(source: _imageSource, maxWidth: 720.0);
    setState(() {
      _image = image;
    });
    if (image != null) {
      _downloadImageUrl = null;
    }
  }

  Future<Null> _showImageSourceSelector() async => showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Image Source'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  this.setState(() {
                    _imageSource = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Camera'),
                onPressed: () {
                  this.setState(() {
                    _imageSource = ImageSource.camera;
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Gallery'),
                onPressed: () {
                  this.setState(() {
                    _imageSource = ImageSource.gallery;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          title: Text(widget.title),
          actions: <Widget>[
            buildCreateProfileButton(),
          ],
        ),
        body: _savingProfile
            ? Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Container(margin: EdgeInsets.all(8.0)),
                    Text('Saving Profile ...'),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              )
            : _buildForm(),
      );

  Widget buildCreateProfileButton() => FlatButton(
        child: Text(_savingProfile ? '' : 'Save Profile'),
        onPressed: () async {
          if (_usernameController.text.isEmpty) {
            _showError('Please provide username');
          } else if (_fullnameController.text.isEmpty) {
            _showError('Please provide full name');
          } else if (_selectedGender == null) {
            _showError('Please select gender');
          } else if (_dateOfBirth == null) {
            _showError('Please select date of birth');
          } else if (_image == null && !currentUser.profileCreated) {
            _showError('Please select a profile image');
          } else if (selectedUniversity == null) {
            _showError('Please select university');
          } else if (selectedClass == null) {
            _showError('Please select class');
          } else if (selectedSection == null) {
            _showError('Please select section');
          } else {
            _setLoading(true);
            _usernameController.text =
                _usernameController.text.replaceAll(' ', '');

            if (_image != null) {
              if (_downloadImageUrl == null) {
                final String downloadUrl = await uploadImage(_image);
                this.setState(() => _downloadImageUrl = downloadUrl);
              }
            }

            String error = await AuthProvider.of(context).createProfile(
                _downloadImageUrl == null
                    ? currentUser.image
                    : _downloadImageUrl,
                _usernameController.text,
                _fullnameController.text,
                _selectedGender,
                _dateOfBirth.millisecondsSinceEpoch,
                selectedSection);
            _showError(error.contains('duplicate key')
                ? 'Username already taken'
                : error);
            _setLoading(false);
          }
        },
      );

  Widget _buildForm() {
    return StreamBuilder(
      stream: AuthProvider.of(context).currentUser,
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) return Container();

        currentUser = snapshot.data;
        if (currentUser.profileCreated) {
          if (_usernameController.text.isEmpty) {
            _usernameController.text = currentUser.username;
          }
          if (_fullnameController.text.isEmpty) {
            _fullnameController.text = currentUser.name;
          }
          if (_selectedGender == null) {
            _selectedGender = currentUser.sex;
          }
          if (_dateOfBirth == null) {
            _dateOfBirth = DateTime.fromMillisecondsSinceEpoch(currentUser.dob);
          }
          if (selectedUniversity == null) {
            selectedUniversity = currentUser.classInfo.university.id;
          }
          if (selectedClass == null) {
            selectedClass = currentUser.classInfo.id;
          }
          if (selectedSection == null) {
            selectedSection = currentUser.section;
          }
        }

        return ListView(
          children: <Widget>[
            _buildUserImage(
                currentUser.profileCreated ? currentUser.image : null),
            Container(
              child: Column(
                children: <Widget>[
                  buildInput('@username', _usernameController),
                  buildInput('Full name', _fullnameController),
                  _pickGender(),
                  _pickDoB(),
                  _pickUniversity(),
                  _pickClass(),
                  SizedBox(height: 8.0),
                  _pickSection(),
                ],
              ),
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
            ),
          ],
        );
      },
    );
  }

  Widget buildInput(String label, TextEditingController controller) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: label,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent))),
      );

  Widget _buildUserImage(String image) => GestureDetector(
        child: Container(
          child: ListTile(
            title: Row(
              children: <Widget>[
                Container(
                  child: _image == null
                      ? image == null
                          ? Icon(
                              Icons.account_circle,
                              size: 130.0,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(image),
                              radius: 60.0,
                            )
                      : CircleAvatar(
                          backgroundImage: FileImage(_image),
                          radius: 60.0,
                        ),
                  height: 130.0,
                  alignment: Alignment.center,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            subtitle: Text('Change Image',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.w700)),
          ),
          color: Colors.grey[200],
          padding: EdgeInsets.only(bottom: 8.0),
        ),
        onTap: () async {
          await _showImageSourceSelector();
          if (_imageSource != null) {
            await getImage();
          }
        },
      );

  Widget _pickGender() => Row(
        children: [
          Expanded(child: Text('Gender')),
          Icon(FontAwesomeIcons.mars),
          Radio<int>(
            value: 1,
            groupValue: _selectedGender,
            onChanged: (gender) {
              this.setState(() {
                _selectedGender = gender;
              });
            },
          ),
          Icon(FontAwesomeIcons.venus),
          Radio<int>(
            value: 2,
            groupValue: _selectedGender,
            onChanged: (gender) {
              this.setState(() {
                _selectedGender = gender;
              });
            },
          ),
          Icon(FontAwesomeIcons.transgender),
          Radio<int>(
            value: 3,
            groupValue: _selectedGender,
            onChanged: (gender) {
              this.setState(() {
                _selectedGender = gender;
              });
            },
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
      );

  Widget _pickDoB() => GestureDetector(
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(child: Text('Date of Birth')),
              Icon(Icons.calendar_today),
              Container(
                margin: EdgeInsets.all(2.0),
              ),
              Text(_dateOfBirth == null
                  ? ''
                  : _dateOfBirth.toIso8601String().substring(0, 10)),
            ],
          ),
          margin: EdgeInsets.only(top: 8.0),
        ),
        onTap: () async {
          final DateTime _selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (_selectedDate != null) {
            this.setState(() {
              _dateOfBirth = _selectedDate;
            });
          }
        },
      );

  Widget _pickUniversity() => Container(
        child: Row(
          children: <Widget>[
            Expanded(child: Text('University')),
            FutureBuilder(
              future: getUniversities(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Please Wait ...');
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.hasData) {
                  final Response response = snapshot.data;
                  final body = jsonDecode(response.body);
                  final result = body['result'];
                  List<UniversityModel> universities = [];
                  Map<String, UniversityModel> universityNames =
                      Map<String, UniversityModel>();
                  result.forEach((university) {
                    universities.add(UniversityModel.fromJson(university));
                    universityNames[UniversityModel.fromJson(university).id] =
                        UniversityModel.fromJson(university);
                  });
                  return DropdownButton(
                    items: universities.map((value) {
                      return DropdownMenuItem<String>(
                        value: value.id,
                        child: Text(value.name),
                      );
                    }).toList(),
                    hint: selectedUniversity != null
                        ? Text(universityNames[selectedUniversity].name)
                        : Text('Select University'),
                    onChanged: (value) {
                      setState(() {
                        selectedClass = null;
                        selectedUniversity = value;
                      });
                    },
                  );
                }
              },
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 8.0),
      );

  Widget _pickClass() => selectedUniversity == null
      ? Container()
      : Container(
          child: Row(
            children: <Widget>[
              Expanded(child: Text('Class')),
              FutureBuilder(
                future: getClassesByUniversity(selectedUniversity),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('Please Wait ...');
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    final Response response = snapshot.data;
                    final body = jsonDecode(response.body);
                    final result = body['result'];
                    List<ClassModel> classes = [];
                    Map<String, ClassModel> classNames =
                        Map<String, ClassModel>();
                    result.forEach((classInfo) {
                      classes.add(ClassModel.fromJson(classInfo));
                      classNames[ClassModel.fromJson(classInfo).id] =
                          ClassModel.fromJson(classInfo);
                    });
                    return DropdownButton(
                      items: classes.map((value) {
                        return DropdownMenuItem<String>(
                          value: value.id,
                          child: Text(value.name),
                        );
                      }).toList(),
                      hint: selectedClass != null
                          ? Text(classNames[selectedClass] != null
                              ? classNames[selectedClass].name
                              : 'Select Class')
                          : Text('Select Class'),
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value;
                        });
                      },
                    );
                  }
                },
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 8.0),
        );

  Widget _pickSection() => selectedClass == null
      ? Container()
      : Row(
          children: <Widget>[
            Expanded(child: Text('Section')),
            FutureBuilder(
              future:
                  makeRequest(Request.GET, '/sections/$selectedClass', null),
              builder: (BuildContext context,
                  AsyncSnapshot<Response> sectionsSnapshot) {
                if (!sectionsSnapshot.hasData) {
                  return Text('Please Wait ...');
                }
                if (sectionsSnapshot.hasError) {
                  return Text(sectionsSnapshot.error.toString());
                }

                final Response response = sectionsSnapshot.data;

                if (response.statusCode == 200) {
                  List<SectionModel> sections = [];
                  Map<String, SectionModel> sectionInfo =
                      Map<String, SectionModel>();
                  final body = jsonDecode(response.body);
                  body['result'].forEach((result) {
                    SectionModel section = SectionModel.fromJson(result);
                    sections.add(section);
                    sectionInfo.addAll({section.id: section});
                  });
                  return DropdownButton(
                    items: sections.map((SectionModel section) {
                      return DropdownMenuItem<String>(
                        value: section.id,
                        child: Text('${section.number}'),
                      );
                    }).toList(),
                    hint: selectedSection != null
                        ? Text(sectionInfo[selectedSection] != null
                            ? 'Number: ${sectionInfo[selectedSection].number}'
                            : 'Select Section')
                        : Text('Select Section'),
                    onChanged: (value) {
                      setState(() {
                        selectedSection = value;
                      });
                    },
                  );
                } else {
                  return Center(child: Text('An Error Occurred'));
                }
              },
            )
          ],
        );
}
