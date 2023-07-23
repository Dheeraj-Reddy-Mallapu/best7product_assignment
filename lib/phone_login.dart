import 'package:best7product_assignment/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'db.dart';
import 'widget_tree.dart';

enum PhoneAuthStatus {
  initial,
  codeSent,
  loading,
  verificationCompleted,
  verificationFailed,
}

class PhoneSignInProvider extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationId = '';
  PhoneAuthStatus status = PhoneAuthStatus.initial;

  Future<void> phoneLogin(String phoneNumber) async {
    status = PhoneAuthStatus.loading;
    notifyListeners();

    verificationCompleted(PhoneAuthCredential credential) async {
      await auth.signInWithCredential(credential);

      status = PhoneAuthStatus.verificationCompleted;
      notifyListeners();
    }

    verificationFailed(FirebaseAuthException e) {
      status = PhoneAuthStatus.verificationFailed;
      notifyListeners();
      if (e.code == 'invalid-phone-number') {
        Get.snackbar('Oops!', 'Check your phone number again');
      }
    }

    codeSent(String verificationId, int? resendToken) async {
      status = PhoneAuthStatus.codeSent;
      this.verificationId = verificationId;
      notifyListeners();
      Get.snackbar('OTP sent', 'Please enter OTP now.');
    }

    codeAutoRetrievalTimeout(String verificationId) {
      this.verificationId = verificationId;
    }

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  verifyOtp(
    String userOtp,
  ) async {
    try {
      PhoneAuthCredential credentials = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: userOtp);

      await auth.signInWithCredential(credentials);

      await db.collection('users').doc(currentUser.uid).get().then((value) async {
        if (!value.exists) {
          await db.collection('users').doc(currentUser.uid).set({
            'uId': currentUser.uid,
            'phoneNumber': currentUser.phoneNumber,
            'name': 'Not Set',
          });
        }
      });

      status = PhoneAuthStatus.verificationCompleted;
      Get.to((const HomeScreen()));
      // notifyListeners();
    } on FirebaseAuthException catch (e) {
      status = PhoneAuthStatus.verificationFailed;
      notifyListeners();
      Get.snackbar('Oops!', e.message.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      status = PhoneAuthStatus.initial;
      verificationId = '';
      // notifyListeners();
      Get.offAll(() => const WidgetTree());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Oops!', e.message.toString());
    }
  }
}
