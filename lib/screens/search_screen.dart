import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const SearchScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // bool loading = false;

  @override
  void initState() {
    _searchController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Screen'),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                onChanged: (value) => {setState(() {})},
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton(
                onPressed: null,
                color: Theme.of(context).primaryColor,
                child: const Text('Search'),
              ),
              const SizedBox(height: 30),
              StreamBuilder(
                // dummy data
                initialData:
                    FirebaseFirestore.instance.collection('users').get(),
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("userName", isEqualTo: _searchController.text)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    if (snapshot.hasData) {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;

                      if (querySnapshot.docs.isEmpty) {
                        return const Text("No Results Found");
                      } else {
                        // Map<String, dynamic> userMap = querySnapshot.docs[0]
                        //     .data() as Map<String, dynamic>;
                        // UserModel searchedUser = UserModel.fromMap(userMap);
                        // return ListTile(
                        //   onTap: () {},
                        //   leading: CircleAvatar(
                        //     backgroundImage: NetworkImage(
                        //       searchedUser.userDpUrl.toString(),
                        //     ),
                        //   ),
                        //   trailing: const Icon(Icons.arrow_right),
                        //   title: Text(searchedUser.userName.toString()),
                        //   subtitle: Text(searchedUser.userEmail.toString()),
                        // );
                        return Expanded(
                          child: ListView.builder(
                            itemCount: querySnapshot.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userMap =
                                  querySnapshot.docs[index].data()
                                      as Map<String, dynamic>;
                              UserModel searchedUser =
                                  UserModel.fromMap(userMap);
                              return ListTile(
                                onTap: () {},
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    searchedUser.userDpUrl.toString(),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_right),
                                title: Text(searchedUser.userName.toString()),
                                subtitle:
                                    Text(searchedUser.userEmail.toString()),
                              );
                            },
                          ),
                        );
                      }

                      // return ListTile(
                      //   title: Text(searchedUser.userName.toString()),
                      //   subtitle: Text(searchedUser.userEmail.toString()),
                      // );
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return const Text("No Data");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
