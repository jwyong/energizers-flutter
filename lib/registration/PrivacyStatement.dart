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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// http posting
import 'package:http/http.dart' as http;

import 'ForgotPword.dart';
import 'Reg2UserInfo.dart';

class PrivacyStatement extends StatefulWidget {
  String searchError;

  PrivacyStatement() : super();

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<PrivacyStatement> {
  @override
  Widget build(BuildContext context) {
    initScreenUtil(context);

    return Scaffold(
      body: RegActiLong(
        hideKeyboardOnly: true,
        hidePrivacyStatement: true,
        gotCloseBtn: true,
        children: <Widget>[
          SizedBox(
            height: respHeight(20),
          ),
          Container(
            decoration: BoxDecoration(
                color: MyColours.white, borderRadius: BorderRadius.circular(5)),
            padding: EdgeInsets.symmetric(
                horizontal: respWidth(20), vertical: respHeight(20)),
            child: Text(
                GlobalVars.getString(GlobalVars.PRIVACY_STATEMENT_CONTENTS)),
          )
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
