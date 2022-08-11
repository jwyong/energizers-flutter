import 'dart:convert';

import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/UplineList.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/widgets/AutoCompleteTextField.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/RegActiLong.dart';
import 'package:energizers/widgets/ScrollActiLong.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// http posting
import 'package:http/http.dart' as http;

import '../HomeTabs.dart';

class Language extends StatefulWidget {
  String searchError;

  Language() : super();

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Language> {
  // basics
  SharedPreferences preferences;

  @override
  void initState() {
    super.initState();

    // set pref to form
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtil(context);

    return ScrollActiLong(
      title: GlobalVars.getString(GlobalVars.LANGUAGE),
      children: <Widget>[
        // english
        MyRaisedBtn(GlobalVars.ENGLISH, () {
          setLang(context, "en");
        }),

        SizedBox(
          height: respHeight(20),
        ),

        // chinese
        MyRaisedBtn(GlobalVars.CHINESE, () {
          setLang(context, "cn");
        }),
      ],
    );
  }

  //===== functions
  void setLang(BuildContext context, String newLang) {
    preferences.setString(GlobalVars.PREF_CURRENT_LANG, newLang);

    rootBundle
        .loadString("assets/locale/localization_$newLang.json")
        .then((prefLang) {
      GlobalVars.strings = json.decode(prefLang);

      // restart app
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
              builder: (context) => HomeTabs(
                    initialTab: 2,
                  )),
          (Route<dynamic> route) => false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
