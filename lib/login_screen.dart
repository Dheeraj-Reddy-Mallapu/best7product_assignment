import 'package:best7product_assignment/phone_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'widget_tree.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  ConfirmationResult? confirmationResult;

  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController otpC = TextEditingController();

  _getOTP(BuildContext context) async {
    final phoneAuthState = Provider.of<PhoneSignInProvider>(context, listen: false);
    String phoneNumber = '+91${phoneNumberC.text}';

    await phoneAuthState.phoneLogin(phoneNumber);
  }

  _signIn(BuildContext context) async {
    final phoneAuthState = Provider.of<PhoneSignInProvider>(context, listen: false);
    String otp = otpC.text;

    await phoneAuthState.verifyOtp(otp);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final phoneAuthState = Provider.of<PhoneSignInProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primaryContainer,
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.primaryContainer,
                  color.primary,
                  // Colors.green,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Image.asset('assets/login.png'),
                ),
                Container(
                  width: 325,
                  height: 400,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Hello!',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color.inverseSurface),
                      ),
                      const Text(
                        'Login to Your Account',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        height: 60,
                        child: TextFormField(
                          controller: phoneNumberC,
                          readOnly: phoneAuthState.status != PhoneAuthStatus.codeSent ? false : true,
                          style: TextStyle(color: color.secondary),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]+')),
                          ],
                          decoration: InputDecoration(
                              prefix: const Text('+91'),
                              prefixStyle: TextStyle(color: color.inverseSurface),
                              labelText: 'Phone Number',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              )),
                        ),
                      ),
                      if (phoneAuthState.status == PhoneAuthStatus.codeSent)
                        SizedBox(
                          width: 260,
                          height: 60,
                          child: Pinput(
                            controller: otpC,
                            androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                            length: 6,
                          ),
                        ),
                      if ((phoneAuthState.status == PhoneAuthStatus.initial ||
                          phoneAuthState.status == PhoneAuthStatus.verificationFailed))
                        InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            width: 250,
                            decoration: const BoxDecoration(
                                boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 1)],
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                gradient:
                                    LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                                  Color(0xFF8A2387),
                                  Color(0xFFE94057),
                                  Color(0xFFF27121),
                                ])),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Get OTP',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onTap: () async {
                            await _getOTP(context);
                          },
                        ),
                      if (phoneAuthState.status == PhoneAuthStatus.codeSent)
                        InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            width: 250,
                            decoration: const BoxDecoration(
                                boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 1)],
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                gradient:
                                    LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                                  Color(0xFF8A2387),
                                  Color(0xFFE94057),
                                  Color(0xFFF27121),
                                ])),
                            child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                )),
                          ),
                          onTap: () async {
                            try {
                              await _signIn(context);
                              Get.to(() => const WidgetTree());
                            } catch (e) {
                              Get.snackbar('Oops!', e.toString());
                            }
                          },
                        ),
                      if (phoneAuthState.status == PhoneAuthStatus.loading)
                        Container(
                          alignment: Alignment.center,
                          width: 250,
                          decoration: const BoxDecoration(
                            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 1)],
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                              Color(0xFF8A2387),
                              Color(0xFFE94057),
                              Color(0xFFF27121),
                            ]),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: LoadingAnimationWidget.prograssiveDots(color: color.background, size: 27),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
