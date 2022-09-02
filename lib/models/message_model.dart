class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? sentTime;

  MessageModel({
    this.messageId,
    this.sender,
    this.text,
    this.seen,
    this.sentTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'seen': seen,
      'sentTime': sentTime?.millisecondsSinceEpoch,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'],
      sender: map['sender'] != null ? map['sender'] as String : null,
      text: map['text'] != null ? map['text'] as String : null,
      seen: map['seen'] != null ? map['seen'] as bool : null,
      sentTime: map['sentTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sentTime'] as int)
          : null,
    );
  }
}
