import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/chat_room_model.dart';
import '../models/user_model.dart';

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
              // expand image on onTap
              Center(
                child: Hero(
                  tag: widget.targetUser.userName.toString(),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        NetworkImage(widget.targetUser.userDpUrl.toString()),
                  ),
                ),
              ),

              Expanded(child: Container()),
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
                    onPressed: () {},
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
