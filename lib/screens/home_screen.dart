import 'package:app/models/firebase_helper.dart';
import 'package:app/models/user_model.dart';
import 'package:app/screens/chat_room.dart';
import 'package:app/screens/search_screen.dart';
import 'package:app/util/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/chat_room_model.dart';
import 'login_screen.dart';

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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.popUntil(
                  context,
                  (route) {
                    return route.isFirst;
                  },
                );
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  MySnackbar.successSnackBar("Logged Out Successfully"),
                );
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatRooms")
                .where("participants.${widget.userModel?.userId}",
                    isEqualTo: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasData) {
                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        querySnapshot.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      Map<String?, dynamic>? participants =
                          chatRoomModel.participants;

                      List<String?> participantsKeys = participants!.keys
                          .where(
                              (element) => element != widget.userModel?.userId)
                          .toList();

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(
                            participantsKeys[0]),
                        builder: (context, data) {
                          if (data.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: Container(),
                            );
                          } else {
                            if (data.hasData) {
                              UserModel targetUser = data.data as UserModel;
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoom(
                                        chatRoom: chatRoomModel,
                                        userModel: widget.userModel!,
                                        firebaseUser: widget.firebaseUser,
                                        targetUser: targetUser,
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(targetUser.userDpUrl!),
                                ),
                                title: Text(targetUser.userName!),
                                subtitle: Text(chatRoomModel.lastMessage!),
                              );
                            } else if (data.hasError) {
                              return MySnackbar.faliureSnackBar(
                                  data.error.toString());
                            } else {
                              return const Center(
                                child: Text(
                                  "No chats yet. Start chatting with someone",
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(
                      child: Text("No chats yet. Start chatting with someone"));
                }
              }
            }),
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
