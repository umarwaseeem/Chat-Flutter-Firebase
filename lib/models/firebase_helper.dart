import 'package:app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {


  static Future<UserModel?> getUserModelById(String? id) async {
    UserModel? userModel;
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection("users").doc(id).get();

    if(snap.data() != null){
      userModel = UserModel.fromMap( snap.data() as Map<String, dynamic> );
    }
    return userModel;
  }



}
