import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../util/vaidators.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool buttonEnabled = false;
  bool loading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // - state functions
  @override
  void initState() {
    emailController.text = '';
    passwordController.text = '';

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // - snackbars
  var loginSnackBar = SnackBar(
    elevation: 0,
    width: double.infinity,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Success',
      message: 'You have logged in successfully',
      contentType: ContentType.success,
    ),
  );

  SnackBar loginErrorSnackBar(FirebaseAuthException e) {
    return SnackBar(
      duration: const Duration(seconds: 3),
      width: double.infinity,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: e.message.toString(),
        contentType: ContentType.failure,
      ),
    );
  }

  void toHomeScreen(UserModel userModel, User firebaseUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userModel: userModel,
          firebaseUser: firebaseUser,
        ),
      ),
    );
  }

  // - login functionality
  void login(String email, String password) async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential? credential;
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .whenComplete(
        () {
          setState(
            () {
              loading = false;
            },
          );
        },
      );

      String? userId = credential.user!.uid;
      String name = email.substring(0, email.indexOf('@'));

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      ScaffoldMessenger.of(context).showSnackBar(loginSnackBar);

      toHomeScreen(userModel, credential.user!);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        loginErrorSnackBar(e),
      );
    }
  }

  // -rendering login ui
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
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      validator: (value) => Validators.emailValidation(value),
                      decoration: const InputDecoration(
                        labelText: 'Email',
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
                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: buttonEnabled
                                  ? () {
                                      login(
                                        emailController.text,
                                        passwordController.text,
                                      );
                                    }
                                  : null,
                              child: const Text('Login'),
                            ),
                          ),
                    const SizedBox(height: 16),
                    const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: const Text('Sign up'),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
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
