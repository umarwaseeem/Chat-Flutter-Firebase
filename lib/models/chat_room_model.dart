class ChatRoomModel {
  String? chatRoomId;
  Map<String?, dynamic>? participants;
  String? lastMessage;

  ChatRoomModel({
    this.chatRoomId,
    this.participants,
    this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatRoomId: map['chatRoomId'],
      participants: map['participants'],
      lastMessage: map['lastMessage'],
    );
  }
}
