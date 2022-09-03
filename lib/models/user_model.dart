// ignore_for_file: public_member_api_docs, sort_constructors_first

class UserModel {
  String? userId;
  String? userName;
  String? userEmail;
  String? userDpUrl; // ? dp = display picture or profile picture url
  String? password;
  bool? isOnline;

  UserModel({
    this.userId,
    this.userName,
    this.userEmail,
    this.userDpUrl,
    this.password,
    this.isOnline,
  });

  // ? you have user model instance, convert it to a map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userDpUrl': userDpUrl,
      'password': password,
      'isOnline': isOnline,
    };
  }

  // ? recieve map and conert it to user model instance
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] != null ? map['userId'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
      userEmail: map['userEmail'] != null ? map['userEmail'] as String : null,
      userDpUrl: map['userDpUrl'] != null ? map['userDpUrl'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      isOnline: map['isOnline'] != null ? map['isOnline'] as bool : null,
    );
  }
}
