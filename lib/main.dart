import 'dart:developer';

import 'package:app/models/firebase_helper.dart';
import 'package:app/models/user_model.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel? currentUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (currentUserModel != null) {
      runApp(
        AppLoggedIn(
          userModel: currentUserModel,
          firebaseUser: currentUser,
        ),
      );
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat With Flutter Firebase',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.blueGrey.shade900,
      ),
      home: const LoginScreen(),
    );
  }
}

class AppLoggedIn extends StatelessWidget {
  final User firebaseUser;

  final UserModel userModel;

  const AppLoggedIn(
      {Key? key, required this.firebaseUser, required this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat With Flutter Firebase',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.blueGrey.shade900,
      ),
      home: HomeScreen(
        firebaseUser: firebaseUser,
        userModel: userModel,
      ),
    );
  }
}
