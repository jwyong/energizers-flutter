import 'dart:convert';

import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/registration/Login.dart';
import 'package:energizers/registration/PrivacyStatement.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RegActiLong extends StatelessWidget {
  SharedPreferences preferences;

  final List<Widget> children;
  final bool gotCloseBtn;
  final bool hideKeyboardOnly;
  final Function gestureFunc;
  final bool hidePrivacyStatement;

  RegActiLong(
      {List<Widget> children,
      bool gotCloseBtn = false,
      Function gestureFunc,
      bool hideKeyboardOnly = false,
      bool hidePrivacyStatement = false})
      : children = children,
        gotCloseBtn = gotCloseBtn,
        hideKeyboardOnly = hideKeyboardOnly,
        gestureFunc = gestureFunc,
        hidePrivacyStatement = hidePrivacyStatement;

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      preferences = prefs;
    });

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/img/reg_bg.png"),
          fit: BoxFit.cover,
        )),
        child: GestureDetector(
            onTap: () {
              if (hideKeyboardOnly) {
                // only hide keyboard
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              } else {
                // hide keyboard AND lose focus
                FocusScope.of(context).requestFocus(FocusNode());
              }

              // additional functions if got
              if (gestureFunc != null) {
                gestureFunc();
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: respWidth(30),
                    right: respWidth(30),
                    bottom: respHeight(10)),
                child: Stack(
                  children: <Widget>[
                    // main content
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (!hidePrivacyStatement)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                topTextItem(context,
                                    GlobalVars.getString("language_option"), 0),
                                Expanded(
                                  child: Container(),
                                ),
                                topTextItem(
                                    context,
                                    GlobalVars.getString(
                                        GlobalVars.PRIVACY_STATEMENT),
                                    1),
                              ],
                            )
                          else
                            SizedBox(
                              height: respHeight(50),
                            ),

                          // logo
                          Padding(
                            child: Image(
                              image: AssetImage('assets/logo/logo_words.png'),
                            ),
                            padding:
                                EdgeInsets.symmetric(horizontal: respWidth(20)),
                          ),

                          // dynamic content
                          for (var widget in this.children) widget,

                          // btm 2 logos
                          Padding(
                            padding: EdgeInsets.only(
                                top: respHeightPercent(5),
                                bottom: respHeight(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                img(
                                    'assets/logo/bs_wwh_logo.png',
                                    MediaQuery.of(context).size.width / 3,
                                    null),
                                img('assets/logo/beltroad_logo.png',
                                    MediaQuery.of(context).size.width / 3, null)
                              ],
                            ),
                          ),
                        ]),

                    // close btn
                    if (gotCloseBtn)
                      Positioned(
                        top: respHeight(50),
                        child: FloatingActionButton(
                          mini: true,
                          elevation: 3,
                          backgroundColor: MyColours.black70a,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: respWidth(30),
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )));
  }

  //===== widgets
  Widget topTextItem(BuildContext context, String text, int index) {
    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            toggleLang(context);
            break;

          case 1: // go to privacy statement
            launch(GlobalVars.PRIVACY_STATEMENT_URL);

//            Navigator.push(
//              context,
//              CupertinoPageRoute(builder: (context) => PrivacyStatement()),
//            );
//            launch(GlobalVars.PRIVACY_URL);
            break;

          default:
            break;
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: respHeight(20)),
        child: Text(
          text,
          style: TextStyle(fontSize: respSP(12), color: MyColours.grey3),
        ),
      ),
    );
  }

  Widget img(String imgPath, double width, double height) {
    return Image(
      width: width,
      height: height,
      image: AssetImage(imgPath),
    );
  }

  //===== functions
  void toggleLang(BuildContext context) {
    // get current language first
    String currentLang =
        preferences.getString(GlobalVars.PREF_CURRENT_LANG) ?? "en";

    // set to other language
    if (currentLang == "cn") {
      currentLang = "en";
    } else {
      currentLang = "cn";
    }
    preferences.setString(GlobalVars.PREF_CURRENT_LANG, currentLang);

    rootBundle
        .loadString("assets/locale/localization_${currentLang}.json")
        .then((prefLang) {
      GlobalVars.strings = json.decode(prefLang);

      // restart app
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false);
    });
  }
}
