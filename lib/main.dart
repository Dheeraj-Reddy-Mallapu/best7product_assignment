import 'package:best7product_assignment/my_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'phone_login.dart';
import 'widget_tree.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PhoneSignInProvider(),
      child: GetMaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const WidgetTree(),
        getPages: [
          GetPage(name: '/', page: () => const WidgetTree()),
          GetPage(name: '/profile', page: () => const MyProfile(isCurrentUser: true))
        ],
      ),
    );
  }
}
