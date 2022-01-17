import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:classroots/models/user.dart';
import 'package:classroots/utils/api.dart' as ApiUtil;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' show Response;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final String _preferenceLoggedIn = 'LOGGED_ID';
final String _preferenceUser = 'USER';
final String _preferenceToken = 'TOKEN';

class AuthBloc extends Object {
  final _loggedIn = BehaviorSubject<bool>();
  final _firebaseUser = BehaviorSubject<FirebaseUser>();
  final _currentUser = BehaviorSubject<UserModel>();
  final _token = BehaviorSubject<String>();

  // Retrieve data from Stream
  Stream<bool> get loggedIn => _loggedIn.stream;

  Stream<FirebaseUser> get firebaseUser => _firebaseUser.stream;

  Stream<UserModel> get currentUser => _currentUser.stream;

  Stream<String> get token => _token.stream;

  // Add data to Stream
  Function(bool) get changeAuthState => _loggedIn.sink.add;

  Function(FirebaseUser) get changeFirebaseUser => _firebaseUser.sink.add;

  Function(UserModel) get changeCurrentUser => _currentUser.sink.add;

  Function(String) get changeToken => _token.sink.add;

  getAuthData() async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    changeAuthState(_sharedPreferences.getBool(_preferenceLoggedIn) == null
        ? false
        : _sharedPreferences.getBool(_preferenceLoggedIn));
    changeCurrentUser(_sharedPreferences.getString(_preferenceUser) == null
        ? null
        : UserModel.fromJson(
            jsonDecode(_sharedPreferences.getString(_preferenceUser))));
  }

  setAuthData(userData, String token) async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    changeToken(token);
    changeCurrentUser(UserModel.fromJson(userData));
    changeAuthState(true);

    await _sharedPreferences.setString(_preferenceUser, jsonEncode(userData));
    await _sharedPreferences.setString(_preferenceToken, token);
    await _sharedPreferences.setBool(_preferenceLoggedIn, true);
  }

  Future<String> loginUser(FirebaseUser user) async {
    String fcmToken = 'not_recieved';

    try {
      fcmToken = await FirebaseMessaging().getToken();
      print('FCM Token for Api Request :$fcmToken');
    } catch (error) {
      print('FCM Token Error: $error');
    }

    final Response response =
        await ApiUtil.postLogin(user.email, user.uid, fcmToken);
    final body = jsonDecode(response.body);
    bool error = body['error'];
    if (!error) {
      final result = body['result'];
      final userData = result['user'];
      final token = result['token'];
      await setAuthData(userData, token);
      changeFirebaseUser(user);
      return 'User authenticated';
    } else {
      return body['result'];
    }
  }

  updateClass(String classId) async {
    try {
      final Response response = await ApiUtil.makeRequest(
          ApiUtil.Request.GET, '/profile/subscribe/$classId', null);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        bool error = body['error'];
        if (!error) {
          final result = body['result'];
          setAuthData(result, _token.value);
          return 'Profile Saved';
        } else {
          return body['result']
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll(', ', '\n')
              .toLowerCase();
        }
      }
    } catch (error) {
      return 'An error occurred';
    }
  }

  Future<String> createProfile(String image, String username, String name,
      int gender, int dob, String sectionInfo) async {
    final Response response = await ApiUtil.putProfile(
        image, username, name, gender, dob, sectionInfo);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      bool error = body['error'];
      if (!error) {
        final result = body['result'];
        setAuthData(result, _token.value);
        return 'Profile Saved';
      } else {
        return body['result']
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll(', ', '\n')
            .toLowerCase();
      }
    } else {
      await logout();
      return 'User Logged Out';
    }
  }

  logout() async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    await _sharedPreferences.clear();
    await _sharedPreferences.setString(_preferenceToken, null);
    FirebaseAuth.instance.signOut();
  }

  dispose() {
    _loggedIn.close();
    _currentUser.close();
  }
}
