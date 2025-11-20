class Validation {
  static checkPassword(String password) {
    if (password.toString().isEmpty && password.toString().length < 6) {
      return 'Fill the password at least 6 characters';
    } else if (password.toString().isEmpty) {
      return 'Fill the password';
    } else if (password.toString().length < 6) {
      return 'You should at least 6 characters';
    }
    return null;
  }

  static checkPasswordLogin(String password) {
    if (password.toString().isEmpty) {
      return 'Fill the password';
    }
    return null;
  }

  // static checkEmail(String email) {
  //   if (email.toString().isEmpty) {
  //     return "Fill the Email";
  //   } else if (email.toString().trim().isEmail() == false) {
  //     return "The email not correct";
  //   } else {
  //     return null;
  //   }
  // }

  static checkTextPoints({required String text, required String points}) {
    if (text.toString().isEmpty) {
      return "الرجاء املأ الحقل بعدد النقاط التي تريدها للخصم";
    } else if ((int.parse(text.toString())) < 300) {
      return "يجب استخدام كحد أدنى  300 نقطة ليتم الخصم";
    } else if ((int.parse(text.toString())) > (int.parse(points.toString()))) {
      return "الرقم أكير من $points";
    }
  }

  static checkText(String text, String name) {
    if (text.toString().isEmpty) {
      return "املأ $name";
    } else {
      return null;
    }
  }

  static checkPhone(String text) {
    if (text.toString().isEmpty) {
      return "املأ الرقم";
    } else if (text.trim().toString().length < 10 ||
        text.trim().toString().length > 10) {
      return "يجب أن يحتوي فقط على 10 أرقام";
    }
  }

  static checkPhoneNumber(String phoneNumber) {
    if (phoneNumber == "") {
      return "يرجى إدخال رقم الهاتف";
    } else if (phoneNumber.length != 10) {
      // Ensure exactly 10 digits
      return "رقم الهاتف يجب أن يحتوي على 10 أرقام بالضبط";
    }
    if (!phoneNumber.startsWith('05')) {
      // Ensure it starts with '5'
      return "يجب أن يبدأ ب 05";
    }

    return null; // Input is valid
  }
}
