import 'dart:developer';

import 'package:app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String? id) async {
    log("getUserModelById: $id");
    UserModel? userModel;
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection("users").doc(id).get().then(
      (value) {
        log("getUserModelById value: ${value.data()}");
        return value;
      },
    );

    if (snap.data() != null) {
      log("getUserModelById: ${snap.data()}");
      userModel = UserModel.fromMap(snap.data() as Map<String, dynamic>);
    } else {
      log("getUserModelById: null");
    }

    return userModel;
  }
}
