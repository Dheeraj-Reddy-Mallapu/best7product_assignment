import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseFirestore.instance;
final currentUser = FirebaseAuth.instance.currentUser!;
Map<String, dynamic> currentUserDetails = {};
List<Map<String, dynamic>> allUsers = [];

retreiveCollection(String collectionName) async {
  // print('collection');
  final snapshot = await db.collection(collectionName).get();
  final dataList = snapshot.docs.map((doc) => doc.data()).toList();
  return dataList;
}
