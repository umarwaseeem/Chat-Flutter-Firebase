import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class MySnackbar {
  static SnackBar successSnackBar(String message) {
    return SnackBar(
      duration: const Duration(seconds: 3),
      width: double.infinity,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: "Success",
        message: message,
        contentType: ContentType.success,
      ),
    );
  }
}
