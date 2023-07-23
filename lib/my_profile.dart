import 'package:best7product_assignment/db.dart';
import 'package:best7product_assignment/home_screen.dart';
import 'package:best7product_assignment/map_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'phone_login.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key, required this.user, required this.isCurrentUser});
  final Map<String, dynamic> user;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final phoneAuthState = Provider.of<PhoneSignInProvider>(context);

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
                trailing: isCurrentUser
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
                                    await db.collection('users').doc(currentUser.uid).update({'name': controller.text});
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
                  width: isCurrentUser ? 100 : 50,
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
                      if (isCurrentUser)
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
              ListTile(
                title: const Text('Photos:'),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye),
                ),
              ),
            ],
          )),
          if (isCurrentUser)
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
  }
}