import 'package:app/models/user_model.dart';
import 'package:app/screens/search_screen.dart';
import 'package:app/util/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const HomeScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                    MySnackbar.successSnackBar("Logged Out Successfully"));
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: const Center(
          child: Text('Home Screen'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print(widget.userModel?.userId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser,
                ),
              ),
            );
          },
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
