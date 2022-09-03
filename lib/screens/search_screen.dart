import 'dart:developer';

import 'package:app/screens/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_room_model.dart';
import '../models/user_model.dart';

var uuid = const Uuid();

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
  ChatRoomModel? chatRoom = ChatRoomModel();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${widget.userModel?.userId}", isEqualTo: true)
        .where("participants.${targetUser.userId}", isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      log("ChatRoomModel found");
      var data = querySnapshot.docs[0].data();
      chatRoom = ChatRoomModel.fromMap(data as Map<String, dynamic>);
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel?.userId.toString(): true,
          targetUser.userId: true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(newChatRoom.chatRoomId)
          .set(
            newChatRoom.toMap(),
          )
          .whenComplete(
            () => log("New chat room created"),
          );
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  Future<dynamic> toChatRoom(BuildContext context, UserModel searchedUser,
      ChatRoomModel chatRoomModel) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoom(
          firebaseUser: widget.firebaseUser,
          targetUser: searchedUser,
          userModel: widget.userModel!,
          chatRoom: chatRoomModel,
        ),
      ),
    );
  }

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
                    .where("userName", isNotEqualTo: widget.userModel?.userName)
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
                                onTap: () async {
                                  chatRoom =
                                      await getChatRoomModel(searchedUser);

                                  if (chatRoom != null) {
                                    // ignore: use_build_context_synchronously
                                    toChatRoom(
                                      context,
                                      searchedUser,
                                      chatRoom!,
                                    );
                                  }
                                },
                                leading: Hero(
                                  tag: searchedUser.userName.toString(),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      searchedUser.userDpUrl.toString(),
                                    ),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_right),
                                title: Text(searchedUser.userName.toString()),
                                subtitle: Text(
                                  searchedUser.userEmail.toString(),
                                ),
                              );
                            },
                          ),
                        );
                      }
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
