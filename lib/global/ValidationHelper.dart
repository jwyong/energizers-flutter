import 'package:energizers/global/GlobalVars.dart';
import 'package:flutter/material.dart';

Map<int, String> formData = Map();

//===== formData
// save value to var for each form field
void setFormData0(String val) {
  formData[0] = val;
}

void setFormData1(String val) {
  formData[1] = val;
}

void setFormData2(String val) {
  formData[2] = val;
}

void setFormData3(String val) {
  formData[3] = val;
}

void setFormData4(String val) {
  formData[4] = val;
}

void setFormData5(String val) {
  formData[5] = val;
}

void setFormData6(String val) {
  formData[6] = val;
}

void setFormData7(String val) {
  formData[7] = val;
}

void setFormData8(String val) {
  formData[8] = val;
}

//===== validation
String validateEmail(String value) {
  String label = GlobalVars.getString("email");

  if (value.isEmpty) {
    return "$label ${GlobalVars.getString("emptyField")}";
  } else {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    if (regex.hasMatch(value)) {
      return null;
    } else {
      return "$label ${GlobalVars.getString("invalidField")}";
    }
  }
}

String pword;

String validatePassword(String fieldVal) {
  String label = GlobalVars.getString("password");
  const length = 8;

  if (fieldVal.length < 8) {
    return "$label ${GlobalVars.getString("lessThanField")} $length ${GlobalVars.getString("characters")}";
  } else {
    pword = fieldVal;
    return null;
  }
}

String confirmPassword(String fieldVal) {
  String label = GlobalVars.getString("password");

  if (fieldVal.isEmpty) {
    // empty "confirm pword" field
    return "$label ${GlobalVars.getString("emptyField")}";
  } else {
    if (fieldVal != pword) {
      // pwords different
      return "$label ${GlobalVars.getString("diffPwordField")}";
    }
    return null;
  }
}

String validateEmpty(String fieldVal) {
  String label = GlobalVars.getString("this_field");

  if (fieldVal == null || fieldVal.isEmpty) {
    return "$label ${GlobalVars.getString("emptyField")}";
  } else {
    return null;
  }
}
