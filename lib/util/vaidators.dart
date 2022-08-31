import 'dart:core';

RegExp numReg = RegExp(r".*[0-9].*");
RegExp letterReg = RegExp(r".*[A-Za-z].*");
RegExp specialReg = RegExp(r".*[!@#$%^&*()_+\-=\[\]{};':" "\\|,.<>/?].*");

class Validators {
  static String? emailValidation(String? value) {
    if (value!.isEmpty) {
      return 'Please enter an email';
    }
    if (!value.contains("@")) {
      return 'Email cannot be without "@';
    }
    return null;
  }

  static String? passwordValidation(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    if (!numReg.hasMatch(value)) {
      return "Password must contain at least one number";
    }
    if (!letterReg.hasMatch(value)) {
      return "Password must contain at least one letter";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }
}
