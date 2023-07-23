import 'package:best7product_assignment/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loading.dart';
import 'welcome_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? _buildLoadingScreen() : _buildContentScreen();
  }

  Widget _buildLoadingScreen() {
    return const Loading();
  }

  Widget _buildContentScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Something Went Wrong!'),
          );
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
