import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math' as Math;

Future<String> uploadImage(File image) async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
  final File file = image;
  final String rand = "${Math.Random().nextInt(10000)}";
  final now = DateTime.now().millisecondsSinceEpoch;
  final StorageReference ref = storage
      .ref()
      .child('images')
      .child('user')
      .child(firebaseUser.uid)
      .child('$now$rand');
  final StorageUploadTask uploadTask = ref.putFile(
    file,
    new StorageMetadata(
      contentLanguage: 'en',
      customMetadata: <String, String>{'activity': 'image'},
    ),
  );
  await uploadTask.onComplete;
  final _imageFileRef = FirebaseStorage.instance.ref().child(ref.path);
  final downloadUrl = await _imageFileRef.getDownloadURL();
  return downloadUrl as String;
}
