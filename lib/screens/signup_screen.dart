import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../util/vaidators.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool buttonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  @override
  void initState() {
    emailController.text = '';
    passwordController.text = '';
    confirmPasswordController.text = '';

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  var signupSnackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Success',
      message: 'Your account was created successfully',
      contentType: ContentType.success,
    ),
  );

  void signUp(String email, String password) async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential? credential;
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .whenComplete(() {
        setState(() {
          loading = false;
        });
      });

      String userId = credential.user!.uid;
      String name = email.substring(0, email.indexOf('@'));

      print("User Id Obtained: $userId");

      UserModel userData = UserModel(
        userId: userId,
        userEmail: email,
        userName: name,
        userDpUrl: "",
        password: password,
        isOnline: true,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(
            userData.toMap(),
          )
          .then(
        (value) {
          Navigator.popUntil(
            context,
            (route) {
              return route.isFirst;
            },
          );

          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => CompleteProfileScreen(
                userModel: userData,
                user: credential!.user!,
              ),
            ),
          );
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(signupSnackBar);
    } on FirebaseAuthException catch (e) {
      print(e.message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: e.message!,
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                onChanged: () {
                  setState(() {
                    buttonEnabled = _formKey.currentState!.validate();
                  });
                },
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create your',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      validator: (value) => Validators.emailValidation(value),
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) =>
                          Validators.passwordValidation(value),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Passwords Do not Match';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                    ),
                    const SizedBox(height: 16),
                    loading
                        ? const Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: buttonEnabled
                                  ? () {
                                      signUp(
                                        emailController.text,
                                        passwordController.text,
                                      );
                                    }
                                  : null,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: const Text(
                            'Already a user? login',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
