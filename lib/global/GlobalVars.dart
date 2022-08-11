import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalVars {
  static const String TAG = "JAY";

  //===== BASICS
  static const String app_name = "Energizers";
  static const String PRIVACY_STATEMENT_URL = "https://www.facebook.com/notes/bs-group-%E6%98%8E%E4%BA%BF%E9%9B%86%E5%9B%A2/bs-energizers-app-privacy-policy/2165426267083834";
  static const String PRIVACY_STATEMENT_CONTENTS = "PRIVACY_STATEMENT_CONTENTS";

  //===== GLOBAL
  // json of strings based on pref language (loaded at main.dart)
  static String getString(String string) {
    return strings[string] ?? string;
  }
  static Map<dynamic, dynamic> strings = {};

  static const String OK = "OK";
  static const String CANCEL = "CANCEL";
  static const String SUBMIT = "SUBMIT";
  static const String LOADING = "LOADING";
  static const String COMING_SOON = "COMING_SOON";

  //===== Response Errors
//  static const Map<String, String> errorCodes = {
//    '4101': 'Email already exists, please login instead',
//    '4102': 'Phone number already exists, please login instead',
//    '4103': 'Phone number format is invalid, please check and try again',
//    '4104': 'The access code provided is invalid, please check and try again',
//    '4105': 'The SMS token provided is invalid, please check and try again',
//    '4106': 'Too many attempts, please try again after some time',
//    '4131': 'Email not registered, please signup instead',
//    '4132': 'The password is incorrect, please check and try again',
//    '4133': 'Your account has been suspended, please contact us',
//    '4161': 'The provided password is too short, please check and try again',
//    '4162': 'Phone number not registered, please signup instead',
//    '4163':
//        'The phone number provided does not belong to this account, please check and try again',
//    '4164':
//        'The new password cannot be the same as the old one, please check and try again',
//  };

  //===== Permissions

  //===== Preferences
  // settings info
  static const String PREF_CURRENT_LANG = "PREF_CURRENT_LANG";

  // serverInfo
  static const String PREF_ACCESS_TOKEN = "PREF_ACCESS_TOKEN";

  // regInfo
  static const String PREF_UPLINE_ID = "PREF_UPLINE_ID"; // numeric
  static const String PREF_UPLINE_CODE = "PREF_UPLINE_CODE"; // alpha
  static const String PREF_UPLINE_NAME = "PREF_UPLINE_NAME";
  static const String PREF_EMAIL = "PREF_EMAIL";
  static const String PREF_NRIC = "PREF_NRIC";
  static const String PREF_MOBILE = "PREF_MOBILE";
  static const String PREF_MEMBER_ID = "PREF_MEMBER_ID"; // MC01234567
  static const String PREF_MEMBER_TYPE_INT = "PREF_MEMBER_TYPE_INT"; // Classic
  static const String PREF_USERNAME = "PREF_USERNAME";
  static const String PREF_PWORD_TEMP = "PREF_PWORD_TEMP";
  static const String PREF_USER_TYPE = "PREF_USER_TYPE"; // starts from 1 not 0

  // user info
  static const String PREF_ADDRESS = "PREF_ADDRESS";
  static const String PREF_POSTCODE = "PREF_POSTCODE";
  static const String PREF_CITY = "PREF_CITY";
  static const String PREF_STATE = "PREF_STATE";
  static const String PREF_COUNTRY = "PREF_COUNTRY";

  // company info
  static const String PREF_COMP_REG_NO = "PREF_COMP_REG_NO";
  static const String PREF_COMP_NAME = "PREF_COMP_NAME";
  static const String PREF_COMP_ADDRESS = "PREF_COMP_ADDRESS";
  static const String PREF_COMP_POSTCODE = "PREF_COMP_POSTCODE";
  static const String PREF_COMP_CITY = "PREF_COMP_CITY";
  static const String PREF_COMP_STATE = "PREF_COMP_STATE";
  static const String PREF_COMP_COUNTRY = "PREF_COMP_COUNTRY";
  static const String PREF_COMP_PHONE = "PREF_COMP_PHONE";

  // bank info
  static const String PREF_BANK_NAME = "PREF_BANK_NAME";
  static const String PREF_BANK_ACC = "PREF_BANK_ACC";

  // others
  static const String PREF_STAGE_INT = "PREF_STAGE_INT";
  static const String PREF_QR_TRANS_ID = "PREF_QR_TRANS_ID"; // transactionID after scanning qr
  static const String PREF_CP = "PREF_CP";
  static const String PREF_VP = "PREF_VP";

  //===== validation

  //===== Registration
  // Registration: Registration
  static const String PRIVACY_STATEMENT = "PRIVACY_STATEMENT";
  static const String AMBASSADOR = "AMBASSADOR";
  static const String USER_INFO = "USER_INFO";
  static const String COMP_INFO = "COMP_INFO";
  static const String BANK_INFO = "BANK_INFO";
  static const String REG_SUCCESS_APPROVE = "REG_SUCCESS_APPROVE";

  // member type
  static const String MEMBERSHIP = "MEMBERSHIP";
  static const String SPECIAL = "SPECIAL";
  static const String CLASSIC = "CLASSIC";
  static const String GOLD = "GOLD";
  static const String PLATINUM = "PLATINUM";

  // Registration: login
  static const String GOOD_MORNING = "GOOD_MORNING";
  static const String GOOD_AFTERNOON = "GOOD_AFTERNOON";
  static const String GOOD_EVENING = "GOOD_EVENING";

  // Reg: ForgotPword
  static const String FORGOT_PWORD_SUCCESS = "FORGOT_PWORD_SUCCESS";
  static const String RESET_PWORD_TITLE = "RESET_PWORD_TITLE";
  static const String RESET_PWORD_SUCCESS = "RESET_PWORD_SUCCESS";

  // Reg: ResetPword

  //======= HomeTabs
  static const String UPLINE = "UPLINE";

  //===== QRTab
  static const String QR_DESC_INITIAL = "QR_DESC_INITIAL";
  static const String QR_UNSUC = "QR_UNSUC";
  static const String QR_CHECK_SUCCESS = "QR_CHECK_SUCCESS";
  static const String QR_FORM_SUBMIT_CONFIRM = "QR_FORM_SUBMIT_CONFIRM";
  static const String QR_FORM_SUCCESS = "QR_FORM_SUCCESS";

  // QR Form
  static const String QR_FORM_TITLE = "QR_FORM_TITLE";
  static const String QR_FORM_DESC = "QR_FORM_DESC";
  static const String QR_FORM_CAR_PLATE_NO = "QR_FORM_CAR_PLATE_NO";
  static const String QR_FORM_CAR_MANU_YEAR = "QR_FORM_CAR_MANU_YEAR";
  static const String YEARS = "YEARS";
  static const String QR_FORM_CAR_TYPE_RECON = "QR_FORM_CAR_TYPE_RECON";
  static const String QR_FORM_CAR_TYPE_OVERHAUL = "QR_FORM_CAR_TYPE_OVERHAUL";
  static const String QR_FORM_BACK_PRESSED = "QR_FORM_BACK_PRESSED";
  static const String QR_FORM_TY = "QR_FORM_TY";

  //===== HistoryTab
  static const String HISTORY_TITLE = "HISTORY_TITLE";
  static const String HISTORY_INST = "HISTORY_INST";
  static const String HISTORY_NO_LIST = "HISTORY_NO_LIST";

  //===== MyStatsTab
  static const String MY_STATS_INST = "MY_STATS_INST";
  static const String MY_STATS_NO = "MY_STATS_NO";
  static const String MY_STATS_CLICK_INST = "MY_STATS_CLICK_INST";

  //===== DownlineTab
  static const String DOWNLINE_TITLE = "DOWNLINE_TITLE";
  static const String DOWNLINE_INST = "DOWNLINE_INST";
  static const String DOWNLINE_NO = "DOWNLINE_NO";

  //===== SettingsTab
  static const String LANGUAGE = "LANGUAGE";
  static const String ENGLISH = "ENGLISH";
  static const String CHINESE = "中文";
}
