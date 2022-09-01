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
  UserModel? userModel =
      await FirebaseHelper.getUserModelById(currentUser?.uid);

  bool loggedIn = false;
  // check if user logged in
  if (currentUser == null) {
    loggedIn = false;
  } else {
    loggedIn = true;
  }
  runApp(MyApp(
    isLoggedIn: loggedIn,
    firebaseUser: currentUser,
    userModel: userModel,
  ));
}

class MyApp extends StatelessWidget {
  final User? firebaseUser;
  final UserModel? userModel;
  final bool isLoggedIn;
  const MyApp(
      {Key? key, required this.isLoggedIn, this.firebaseUser, this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == false) {
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.blueGrey.shade900,
      ),
      home: HomeScreen(
        userModel: userModel,
        firebaseUser: firebaseUser,
      ),
    );
  }
}
