import 'package:best7product_assignment/loading.dart';
import 'package:best7product_assignment/messaging_service.dart';
import 'package:best7product_assignment/my_profile.dart';
import 'package:best7product_assignment/view_all_users.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'db.dart';
import 'map_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  initData() async {
    try {
      final dataList = await retreiveCollection('users');
      allUsers = dataList;
    } catch (e) {
      Get.snackbar('Oops!', e.toString());
    }

    isLoading = false;
    setState(() {});
  }

  //// notification service
  final _messagingService = MessagingService();

  @override
  void initState() {
    initData();
    _messagingService.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    if (!isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Home Screen', style: TextStyle(color: color.primary)),
          actions: [
            ElevatedButton(
              onPressed: () {
                // final user = allUsers.where((element) => element['phoneNumber'] == currentUser.phoneNumber).first;
                Get.to(() => const MyProfile(isCurrentUser: true));
              },
              child: const Text('Profile'),
            ),
          ],
        ),
        body: Column(
          children: [
            ListTile(
              title: ElevatedButton(
                onPressed: () => Get.to(() => const AllUsersMapView()),
                child: const Text('Map View'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: allUsers.length - 1,
                itemBuilder: (context, index) {
                  final filteredUsers = allUsers.where((element) => element['uId'] != currentUser.uid).toList();
                  final user = filteredUsers[index];

                  return ListTile(
                    leading: Text(
                      user['name'],
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'View User details',
                            onPressed: () => Get.to(() => MyProfile(user: user, isCurrentUser: false)),
                            icon: const Icon(Icons.dehaze_outlined),
                          ),
                          IconButton(
                            tooltip: 'View location in Map',
                            onPressed: () {
                              if (user['location'] != null) {
                                Get.to(() => MyMapView(
                                      isEditMode: false,
                                      lat: user['location']['lat'],
                                      lng: user['location']['lng'],
                                    ));
                              } else {
                                Get.snackbar('Oops!', 'Location not set');
                              }
                            },
                            icon: const Icon(Icons.remove_red_eye),
                          ),
                        ],
                      ),
                    ),
                  );
                  // return ElevatedButton(onPressed: () => Get.to(() => const MyMapView()), child: const Text('MapView'));
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return const Loading();
    }
  }
}
