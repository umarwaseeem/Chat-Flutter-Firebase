// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatRoomModel {
  String? chatRoomId;
  List<String>? participants;

  ChatRoomModel({
    this.chatRoomId,
    this.participants,
  });



  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatRoomId': chatRoomId,
      'participants': participants,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatRoomId: map['chatRoomId'] != null ? map['chatRoomId'] as String : null,
      participants: map['participants'] != null ? List<String>.from((map['participants'] as List<String>)) : null,
    );
  }

}
