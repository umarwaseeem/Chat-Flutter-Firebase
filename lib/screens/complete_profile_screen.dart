import 'dart:developer';
import 'dart:io';

import 'package:app/screens/home_screen.dart';
import 'package:app/util/snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User user;
  const CompleteProfileScreen(
      {Key? key, required this.userModel, required this.user})
      : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  File? imageFile;
  TextEditingController nameConroller = TextEditingController();
  bool buttonEnabled = false;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  bool uploaded = false;

  void selectImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      cropTheImage(pickedImage);
    }
  }

  void cropTheImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      compressQuality: 20,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  SnackBar errorSnackBar(String message) {
    return SnackBar(
      duration: const Duration(seconds: 3),
      width: double.infinity,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
    );
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Photo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                title: const Text("Select from gallery"),
                leading: const Icon(Icons.photo_album),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                title: const Text("Take a photo"),
                leading: const Icon(Icons.camera_alt),
              ),
            ],
          ),
        );
      },
    );
  }

  void uploadData() async {
    setState(() {
      loading = true;
    });
    try {
      if (imageFile != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("profilePictures")
            .child(widget.userModel.userName.toString())
            .putFile(
              imageFile!,
            );

        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        widget.userModel.userDpUrl = imageUrl;
      }
      String fullName = nameConroller.text;
      widget.userModel.userName = fullName;

      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.userId)
          .set(
            widget.userModel.toMap(),
          )
          .then(
        (value) {
          log("\x1B[32muploaded\x1B[0m");
          setState(() {
            loading = false;
          });
          MySnackbar.successSnackBar("Profile info set successfully");
          Navigator.popUntil(
            context,
            (route) {
              return route.isFirst;
            },
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userModel: widget.userModel,
                firebaseUser: widget.user,
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
      ),
      body: SafeArea(
        child: Form(
          onChanged: () {
            setState(() {
              buttonEnabled = _formKey.currentState!.validate();
            });
          },
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            padding: const EdgeInsets.all(30),
            child: ListView(
              children: [
                CupertinoButton(
                  onPressed: () {
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        imageFile == null ? null : FileImage(imageFile!),
                    radius: 50,
                    child: imageFile == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  controller: nameConroller,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16),
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: buttonEnabled
                            ? () {
                                uploadData();
                              }
                            : null,
                        child: const Text("Submit"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
