import 'dart:developer';

import 'package:app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_room_model.dart';
import '../models/user_model.dart';

var uuid = const Uuid();

class ChatRoom extends StatefulWidget {
  final UserModel targetUser;
  final UserModel userModel;
  final ChatRoomModel? chatRoom;
  final User? firebaseUser;
  const ChatRoom(
      {Key? key,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController messageController = TextEditingController();

  bool online = true;

  @override
  void initState() {
    messageController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    String? message = messageController.text.trim();
    messageController.clear();

    if (message.isNotEmpty) {
      MessageModel messageModel = MessageModel(
        text: message,
        messageId: uuid.v1(),
        sender: widget.userModel.userId,
        sentTime: DateTime.now(),
        seen: false,
      );

      // await not used, can store message when internet not available
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom?.chatRoomId)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(
            messageModel.toMap(),
          )
          .whenComplete(
        () {
          log("Message sent");
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  NetworkImage(widget.targetUser.userDpUrl.toString()),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.targetUser.userName.toString()),
                if (online)
                  const Text(
                    "Online",
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatRooms")
                        .doc(widget.chatRoom?.chatRoomId)
                        .collection("messages")
                        .orderBy("sentTime", descending: true)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.hasData) {
                          QuerySnapshot querySnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                            reverse: true,
                            itemCount: querySnapshot.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(
                                querySnapshot.docs[index].data()
                                    as Map<String, dynamic>,
                              );
                              return Row(
                                mainAxisAlignment: (currentMessage.sender ==
                                        widget.userModel.userId)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender ==
                                              widget.userModel.userId)
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const Center(
                            child: Text("No messages"),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.keyboard_voice_rounded,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
                // styling
              ),
            ],
          ),
        ),
      ),
    );
  }
}
