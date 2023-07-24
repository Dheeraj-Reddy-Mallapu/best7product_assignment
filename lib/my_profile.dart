import 'dart:io';

import 'package:best7product_assignment/db.dart';
import 'package:best7product_assignment/home_screen.dart';
import 'package:best7product_assignment/loading.dart';
import 'package:best7product_assignment/map_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'firebase_storage.dart';
import 'phone_login.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key, required this.isCurrentUser, this.user});
  final Map<String, dynamic>? user;
  final bool isCurrentUser;

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool isLoading = true;
  late Map<String, dynamic> user;

  List imageURLs = [];

  initData() async {
    try {
      await db.collection('users').where('uId', isEqualTo: currentUser.uid).get().then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          user = docSnapshot.data();
        }
      });
    } catch (e) {
      Get.snackbar('Oops!', e.toString());
    }

    if (user['imageURLs'] != null) {
      imageURLs = user['imageURLs'];
    }

    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    user = widget.user ?? {};
    if (widget.isCurrentUser) {
      initData();
    } else {
      isLoading = false;
      if (user['imageURLs'] != null) {
        imageURLs = user['imageURLs'];
      }
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final phoneAuthState = Provider.of<PhoneSignInProvider>(context);

    if (!isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Name:'),
                    subtitle: Text(user['name']),
                    trailing: widget.isCurrentUser
                        ? IconButton(
                            onPressed: () {
                              TextEditingController controller = TextEditingController(text: user['name']);
                              Get.defaultDialog(
                                  title: 'Edit Name',
                                  content: TextFormField(
                                    controller: controller,
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await db
                                            .collection('users')
                                            .doc(currentUser.uid)
                                            .update({'name': controller.text});
                                        Get.snackbar('Hurray!', 'Name set successfully');
                                        Get.offAll(() => const HomeScreen());
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ]);
                            },
                            icon: const Icon(Icons.edit),
                          )
                        : const Text(''),
                  ),
                  ListTile(
                    title: const Text('Phone Number:'),
                    subtitle: Text(user['phoneNumber'].toString()),
                  ),
                  ListTile(
                    title: const Text('Location:'),
                    trailing: SizedBox(
                      width: widget.isCurrentUser ? 100 : 50,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (user['location'] == null) {
                                Get.snackbar('Oops!', 'Location not set');
                              } else {
                                Get.to(() => MyMapView(
                                      isEditMode: false,
                                      lat: user['location']['lat'],
                                      lng: user['location']['lng'],
                                    ));
                              }
                            },
                            icon: const Icon(Icons.remove_red_eye),
                          ),
                          if (widget.isCurrentUser)
                            IconButton(
                              onPressed: () {
                                Get.to(() => MyMapView(
                                      isEditMode: true,
                                      lat: user['location'] != null ? user['location']['lat'] : 17.416330078551702,
                                      lng: user['location'] != null ? user['location']['lng'] : 78.47494613301858,
                                    ));
                              },
                              icon: const Icon(Icons.edit),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Photos:',
                          style: TextStyle(fontSize: 18),
                        ),
                        if (widget.isCurrentUser)
                          TextButton.icon(
                            onPressed: () => _pickImage(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Photo'),
                          ),
                      ],
                    ),
                  ),
                  if (user['imageURLs'] != null)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          mainAxisExtent: 250,
                          childAspectRatio: 2,
                        ),
                        itemCount: user['imageURLs'].length,
                        itemBuilder: (context, index) {
                          final imageUrl = user['imageURLs'][index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (widget.isCurrentUser)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => phoneAuthState.signOut(),
                    child: const Text('Sign Out'),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return const Loading();
    }
  }

  final ImagePicker imgpicker = ImagePicker();
  String imagepath = "";

  Future<void> _pickImage() async {
    var pickedFile = await imgpicker.pickImage(source: ImageSource.gallery);
    File imageFile;
    if (pickedFile != null) {
      imagepath = pickedFile.path;

      imageFile = File(imagepath); //convert Path to File

      String imageUrl = await uploadImageToFirebase(imageFile, currentUser.uid);
      setState(() {
        imageURLs.add(imageUrl);
      });
    } else {
      Get.snackbar('Oops!', 'No image is selected');
    }
  }
}
