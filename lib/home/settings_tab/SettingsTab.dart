import 'dart:convert';

import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/home/settings_tab/BankInfo.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../HomeTabs.dart';
import 'CompInfo.dart';
import 'Language.dart';
import 'MyInfo.dart';

class SettingsTab extends StatefulWidget {
  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab>
    with AutomaticKeepAliveClientMixin<SettingsTab> {
  // basics
  SharedPreferences preferences;

  String userName = "User";

  @override
  void initState() {
    super.initState();

    // get data from pref
    SharedPreferences.getInstance().then((prefs) {
      userName = prefs.getString(GlobalVars.PREF_USERNAME) ?? "User";

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: respHeight(20), horizontal: respWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // title
            homeTabsHeading(GlobalVars.getString("settings")),

            // profile img
            profileAvatar(),

            // profile name
            homeTabsSecondary(userName),
            SizedBox(
              height: respHeight(40),
            ),

            // settings items
            settingsItem(Icons.person, GlobalVars.getString("user_info"), () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => MyInfo()),
              );
            }),
            settingsItem(
                Icons.card_travel, GlobalVars.getString(GlobalVars.COMP_INFO),
                () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => CompInfo()),
              );
            }),
            settingsItem(
                Icons.credit_card, GlobalVars.getString(GlobalVars.BANK_INFO),
                () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => BankInfo()),
              );
            }),
            settingsItem(
                Icons.language, GlobalVars.getString(GlobalVars.LANGUAGE), () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => Language()),
              );
            }),

            poweredBySoapp(),
          ],
        ));
  }

  //===== widgets
  Widget profileAvatar() {
    return Expanded(
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: respHeight(30)),
      child: CircleAvatar(
          backgroundColor: MyColours.grey3,
          radius: double.infinity,
          child: Text(
            userName.substring(0, 1).toUpperCase(),
            style: TextStyle(color: MyColours.purple1, fontSize: respSP(50)),
          )),
    ));
  }

  Widget settingsItem(IconData icon, String label, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: respHeight(15)),
        padding: EdgeInsets.symmetric(
            vertical: respHeight(15), horizontal: respWidth(30)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: MyColours.purple1),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: respWidth(10)),
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
