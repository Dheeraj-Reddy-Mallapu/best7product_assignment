import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'db.dart';

Future<String> uploadImageToFirebase(File imageFile, String userId) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('users/$userId/photos/$fileName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot storageSnapshot = await uploadTask;
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();

    await db.collection('users').doc(currentUser.uid).update({
      'imageURLs': FieldValue.arrayUnion([downloadUrl])
    });

    Get.snackbar('Success!', 'Added image');
    return downloadUrl;
  } catch (e) {
    Get.snackbar('Oops!', e.toString());
    throw Exception('Failed to upload image.');
  }
}
