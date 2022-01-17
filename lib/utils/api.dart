import 'package:http/http.dart';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:async' show Future;
import 'package:shared_preferences/shared_preferences.dart';

enum Request { GET, POST, PUT, DELETE }

final String baseUrl = 'https://classroots.herokuapp.com/api/';
// final String baseUrl = 'http://192.168.0.105:3000/api/';

/* auth */
postLogin(
  String email,
  String password,
  String fcmToken,
) async =>
    await makeRequest(Request.POST, 'login',
        {'email': email, 'password': password, 'fcmToken': fcmToken});
putProfile(String image, String username, String name, int gender, int dob,
        String section) async =>
    await makeRequest(Request.PUT, 'profile/create', {
      'image': image,
      'username': username,
      'name': name,
      'sex': gender,
      'dob': dob,
      'section': section
    });

/* university */
getUniversities() async => await makeRequest(Request.GET, 'universities', null);
/* class */
Future<Response> getClasses() async =>
    await makeRequest(Request.GET, 'classes', null);
Future<Response> getClassesByUniversity(String university) async =>
    await makeRequest(Request.GET, 'classes/$university', null);

/* Subscriptions */
getSubscriptions() async =>
    await makeRequest(Request.GET, 'profile/subscriptions', null);
postSubscription(String classId) async => await makeRequest(
    Request.POST, '/profile/subscriptions', {'class': classId});
deleteSubscription(String classId) async =>
    await makeRequest(Request.DELETE, '/profile/subscriptions/$classId', null);

/* post */
createPost(String description, List<String> images, String section) async =>
    await makeRequest(Request.POST, 'posts/create/$section',
        {'description': description, 'images': images});

getPosts() async =>
    await makeRequest(Request.GET, 'posts/subscribed/class', null);
Future<Response> getPostTagged(String tag) async =>
    await makeRequest(Request.GET, 'posts/tagged/$tag', null);
Future<Response> getPostUser(String id) async =>
    await makeRequest(Request.GET, 'posts/user/$id', null);

getLikePost(
  String id,
) async =>
    await makeRequest(Request.GET, 'posts/like/$id', null);

getPostComment(String id) async =>
    await makeRequest(Request.GET, 'posts/comment/$id', null);

postComment(String id, String comment) async =>
    await makeRequest(Request.POST, 'posts/comment/$id', {'comment': comment});

/* profile */
getUserProfile(String username) async =>
    await makeRequest(Request.GET, 'profile/username/$username', null);

Future<Response> makeRequest(
  Request method,
  String route,
  dynamic body,
) async {
  switch (method) {
    case Request.GET:
      return get(getUrl(route), headers: setHeaders(await getToken));
    case Request.POST:
      return post(getUrl(route),
          body: encodeJson(body), headers: setHeaders(await getToken));
    case Request.PUT:
      return put(getUrl(route),
          body: encodeJson(body), headers: setHeaders(await getToken));
    case Request.DELETE:
      return delete(getUrl(route), headers: setHeaders(await getToken));
    default:
      return get(getUrl(route), headers: setHeaders(await getToken));
  }
}

Future<String> get getToken async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  String token = sharedPreferences.getString('TOKEN');
  return token == null ? 'not_logged_in' : token;
}

getUrl(String route) => '$baseUrl$route';
encodeJson(body) => jsonEncode(body);
Map<String, String> setHeaders(token) => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token
    };
