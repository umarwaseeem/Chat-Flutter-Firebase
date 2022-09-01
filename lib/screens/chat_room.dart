import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String userName;
  final String imageUrl;
  const ChatRoom({Key? key, required this.userName, required this.imageUrl})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController messageController = TextEditingController();

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
        title: Text(widget.userName),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Hero(
                  tag: widget.userName,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(widget.imageUrl),
                  ),
                ),
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
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
