import 'dart:convert';

import 'package:energizers/registration/ForgotPword.dart';
import 'package:energizers/registration/Login.dart';
import 'package:energizers/registration/Reg1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Application.dart';
import 'global/MyColours.dart';
import 'global/GlobalVars.dart';
import 'home/HomeTabs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // get preferences
  SharedPreferences.getInstance().then((prefs) {
    // set pref language
    String currentLang = prefs.getString(GlobalVars.PREF_CURRENT_LANG) ?? "en";
    rootBundle
        .loadString("assets/locale/localization_${currentLang}.json")
        .then((prefLang) {
      GlobalVars.strings = json.decode(prefLang);

      // setup portrait orientation then run app
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        // set pref language

        runApp(MyApp(prefs));
      });
    });
  });
}

class MyApp extends StatelessWidget {
  SharedPreferences preferences;

  MyApp(this.preferences);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white, canvasColor: MyColours.purple1),
      home: goToPrefPage(preferences),
    );
  }
}

Widget goToPrefPage(SharedPreferences preferences) {
  if (preferences.getInt(GlobalVars.PREF_STAGE_INT) == 1) {
    // logged in
    return HomeTabs();
  } else {
    return Login();
  }
}
