import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Text(
              'best7product',
              style: TextStyle(
                fontSize: 32,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            width: 300,
            child: Container(
                decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/logo.png')),
            )),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            label: const Text('Login with Phone Number'),
            icon: const Icon(Icons.phone),
            onPressed: () {
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}
