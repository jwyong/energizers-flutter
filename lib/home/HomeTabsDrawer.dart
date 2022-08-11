import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/CPVPList.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/registration/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/MyText.dart';

class HomeTabsDrawer extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomeTabsDrawer> {
  // basics
  SharedPreferences preferences;
  String userName = "";
  String memberIDStr = "";
  int memberTypeInt = 1;
  int userTypeInt = 1;
  int cp = 0, vp = 0;

  // for graphQL
  GraphQLClient graphQLClient;

  @override
  void initState() {
    super.initState();

    // get data from pref
    SharedPreferences.getInstance().then((prefs) {
      // init qr with auth token
      graphQLClient = initGraphQL(
          accessToken: prefs.getString(GlobalVars.PREF_ACCESS_TOKEN));

      // set user info
      memberIDStr = prefs.getString(GlobalVars.PREF_MEMBER_ID) ?? "";
      userName = prefs.getString(GlobalVars.PREF_USERNAME) ?? "";
      userTypeInt = prefs.getInt(GlobalVars.PREF_USER_TYPE) ?? 1;

      // only ambassadors have cp/vp
      // get latest points from server
      getCPVP();

      if (userTypeInt == 1) {
        // show cp/vp from pref first
        cp = prefs.getInt(GlobalVars.PREF_CP) ?? 0;
        vp = prefs.getInt(GlobalVars.PREF_VP) ?? 0;
      } else {
        // show membership type if member
        memberTypeInt = prefs.getInt(GlobalVars.PREF_MEMBER_TYPE_INT)?? 1;
      }

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return navDrawer();
  }

  //===== widgets
  Widget navDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.symmetric(
            vertical: respHeight(30), horizontal: respWidth(20)),
        children: <Widget>[
          // welcome, xxx
          regBodyHeader("${GlobalVars.getString("welcome")}, $userName",
              EdgeInsets.all(0),
              textAlignment: TextAlign.start, needBold: true),
          SizedBox(
            height: respHeight(5),
          ),

          // userID
          regBodyTxt(memberIDStr, EdgeInsets.only(top: respHeight(20)),
              textAlignment: TextAlign.start),

          // cp, vp - only for ambassadors
          if (userTypeInt == 1)
            regBodyTxt("$cp CP", EdgeInsets.only(top: respHeight(20)),
                textAlignment: TextAlign.start),
          if (userTypeInt == 1)
            regBodyTxt("$vp VP", EdgeInsets.only(bottom: respHeight(20)),
                textAlignment: TextAlign.start),

          // membership type - only for members
          if (userTypeInt == 2)
            regBodyTxt(getMemberTypeStr(),
                EdgeInsets.only(bottom: respHeight(20)),
                textAlignment: TextAlign.start),

          // drawer items
          Divider(color: Colors.white),
          drawerItem(Icons.monetization_on, GlobalVars.getString("market"), () {
            toastMsg(context, GlobalVars.getString(GlobalVars.COMING_SOON));
          }),

          // universal
          drawerItem(Icons.exit_to_app, GlobalVars.getString("logout"), logout),
        ],
      ),
    );
  }

  Widget drawerItem(IconData icon, String label, Function onTap) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: Colors.white,
              ),
              regBodyTxt(label, EdgeInsets.symmetric(horizontal: respWidth(10)))
            ],
          ),
        ),
        Divider(
          color: Colors.white,
        )
      ],
    );
  }

  //===== funcs
  String getMemberTypeStr() {
    switch (memberTypeInt) {
      case 1:
        return GlobalVars.getString(GlobalVars.SPECIAL);

      case 2:
        return GlobalVars.getString(GlobalVars.CLASSIC);

      case 3:
        return GlobalVars.getString(GlobalVars.GOLD);

      case 4:
        return GlobalVars.getString(GlobalVars.PLATINUM);
    }
  }

  void logout() {
    // set to pref
    preferences.setInt(GlobalVars.PREF_STAGE_INT, 0);

    // go to login page
    Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false);
  }

  //===== http funcs
  void getCPVP() async {
    print("${GlobalVars.TAG} _State: getCPVP ");

    QueryOptions options = QueryOptions(
      document: queryDrawer,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (result.hasErrors) {
      print("${GlobalVars.TAG} _State: getCPVP ");
      respError(context, result);

      // no need do anything if error

    } else {
      respSuccess(result.data);
    }
  }

  void respSuccess(data) {
    // get resp
    var respModel = CPVPList.fromJson(data);
    List<CPVP> cpVpList = respModel.cpVpList;

    List<int> cpList =
        cpVpList.map((item) => int.parse(item.cpEarnerd)).toList();
    List<int> vpList =
        cpVpList.map((item) => int.parse(item.vpEarned)).toList();

    setState(() {
      // calc total cp/vp
      cp = cpList.fold(0, (p, c) => p + c);
      vp = vpList.fold(0, (p, c) => p + c);

      print("${GlobalVars.TAG} _State: respSuccess memberCode = ${respModel.memberCode}");

      // save to prefs
      switch (respModel.memberCode) {
        case "MS":
          memberTypeInt = 1;
          break;

        case "MC":
          memberTypeInt = 2;
          break;

        case "MG":
          memberTypeInt = 3;
          break;

        case "MP":
          memberTypeInt = 4;
          break;
      }
      memberIDStr = respModel.memberCode + respModel.memberID;

      preferences.setString(GlobalVars.PREF_MEMBER_ID, memberIDStr);
      preferences.setInt(GlobalVars.PREF_MEMBER_TYPE_INT, memberTypeInt);
      preferences.setInt(GlobalVars.PREF_CP, cp);
      preferences.setInt(GlobalVars.PREF_VP, vp);
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
