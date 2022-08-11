import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//===== POWERED BY SOAPP
Widget poweredBySoapp() {
  return RichText(
    text: TextSpan(children: [
      TextSpan(text: "Powered By ", style: TextStyle(color: Colors.black)),
      TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch("https://www.soapptech.com/");
            },
          text: "Soapp",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
    ]),
  );
}

//===== registration
Widget regBodyHeader(String text, EdgeInsets padding,
    {TextAlign textAlignment = TextAlign.center, bool needBold = false}) {
  return Padding(
    child: Text(
      text,
      textAlign: textAlignment,
      style: TextStyle(
          color: Colors.white,
          fontSize: respSP(20),
          fontWeight: needBold ? FontWeight.bold : FontWeight.normal),
    ),
    padding: padding,
  );
}

Widget regBodyTxt(String text, EdgeInsets padding,
    {TextAlign textAlignment = TextAlign.center}) {
  return Padding(
    child: Text(
      text,
      textAlign: textAlignment,
      style: TextStyle(color: Colors.white, fontSize: respSP(16)),
    ),
    padding: padding,
  );
}

Widget segContTxt2(String text) {
  return Padding(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: respSP(14)),
    ),
    padding: EdgeInsets.symmetric(horizontal: respWidth(20)),
  );
}

Widget segContTxt4(String text) {
  return Padding(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: respSP(12)),
    ),
    padding: EdgeInsets.symmetric(horizontal: respWidth(10)),
  );
}

//===== hometabs
Widget homeTabsHeading(String text,
    {TextAlign textAlignment = TextAlign.center}) {
  return Text(
    text.toUpperCase(),
    textAlign: textAlignment,
    style: TextStyle(
        color: MyColours.grey10,
        fontSize: respSP(20),
        fontWeight: FontWeight.bold),
  );
}

Widget homeTabsSecondary(String text,
    {TextAlign textAlignment = TextAlign.center}) {
  return Text(
    text.toUpperCase(),
    textAlign: textAlignment,
    style: TextStyle(color: MyColours.grey10, fontSize: respSP(18)),
  );
}
