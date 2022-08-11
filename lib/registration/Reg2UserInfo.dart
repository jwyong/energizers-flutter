import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/home/HomeTabs.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/RegActiLong.dart';
import 'package:energizers/widgets/RegActiShort.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'ForgotPword.dart';
import 'Reg3CompInfo.dart';

class Reg2UserInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Reg2UserInfo> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode countryFocus = FocusNode();

  TextEditingController cont1 = TextEditingController(),
      cont2 = TextEditingController(),
      cont3 = TextEditingController(),
      cont4 = TextEditingController(),
      cont5 = TextEditingController();

  // obs
  bool isBtnEnabled = true;

  bool isPwordObscured = true;
  bool isPword2Obscured = true;

  // for segmented controls
  int accountTypeIndex = 0;
  int memberTypeIndex = 0;

  @override
  void initState() {
    super.initState();

    formData.clear();

    SharedPreferences.getInstance().then((prefs) {
      // set pref to fields
      formData[1] = prefs.get(GlobalVars.PREF_ADDRESS);
      formData[2] = prefs.get(GlobalVars.PREF_POSTCODE);
      formData[3] = prefs.get(GlobalVars.PREF_CITY);
      formData[4] = prefs.get(GlobalVars.PREF_STATE);
      formData[5] = prefs.get(GlobalVars.PREF_COUNTRY);

      // set for controller
      cont1.text = formData[1];
      cont2.text = formData[2];
      cont3.text = formData[3];
      cont4.text = formData[4];
      cont5.text = formData[5];

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtil(context);

    return Scaffold(
      body: RegActiLong(
        gotCloseBtn: true,
        children: <Widget>[
          // user info
          Padding(
            padding: EdgeInsets.symmetric(vertical: respHeight(20)),
            child: Text(
              GlobalVars.getString("user_info"),
              style: TextStyle(fontSize: respSP(20), color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          // form
          regForm(),

          // next btn
          SizedBox(
            height: respHeight(25),
          ),
          MyRaisedBtn(
              GlobalVars.getString("next"),
              isBtnEnabled
                  ? () {
                      submitBtnOnClick(null);
                    }
                  : null),
        ],
      ),
    );
  }

  //===== widgets
  Widget regForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1 - address
          MyFormField(
            maxLines: 3,
            hintText: GlobalVars.getString("address"),
            controller: cont1,
            validator: validateEmpty,
            onSaved: setFormData1,
            textInputAction: TextInputAction.newline,
          ),

          // 2 - postcode
          MyFormField(
//            maxLength: 10,
            hintText: GlobalVars.getString("postcode"),
            controller: cont2,
            validator: validateEmpty,
            textInputType: TextInputType.number,
            onFieldSubmitted: focusForPostcode,
            onSaved: setFormData2,
          ),

          // 3 - city
          MyFormField(
            controller: cont3,
            hintText: GlobalVars.getString("city"),
            focusNode: cityFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForCity,
            onSaved: setFormData3,
          ),

          // 4 - state
          MyFormField(
            hintText: GlobalVars.getString("state"),
            controller: cont4,
            focusNode: stateFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForState,
            onSaved: setFormData4,
          ),

          // 5 - country
          MyFormField(
            controller: cont5,
            hintText: GlobalVars.getString("country"),
            focusNode: countryFocus,
            validator: validateEmpty,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData5,
          ),
        ],
      ),
    );
  }

  //form func
  void focusForPostcode(String value) {
    FocusScope.of(context).requestFocus(cityFocus);
  }

  void focusForCity(String value) {
    FocusScope.of(context).requestFocus(stateFocus);
  }

  void focusForState(String value) {
    FocusScope.of(context).requestFocus(countryFocus);
  }

  //===== normal funcs
  void submitBtnOnClick(String val) {
    // validate
    if (formKey.currentState.validate()) {
      // save form data to var
      formKey.currentState.save();

      // save form data to pref
      preferences.setString(GlobalVars.PREF_ADDRESS, formData[1]);
      preferences.setString(GlobalVars.PREF_POSTCODE, formData[2]);
      preferences.setString(GlobalVars.PREF_CITY, formData[3]);
      preferences.setString(GlobalVars.PREF_STATE, formData[4]);
      preferences.setString(GlobalVars.PREF_COUNTRY, formData[5]);

      // pass pword to next page
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => Reg3CompInfo()),
      );
    }
  }
}
