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
import 'Reg4BankInfo.dart';

class Reg3CompInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Reg3CompInfo> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode nameFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();

  TextEditingController cont0 = TextEditingController(),
      cont1 = TextEditingController(),
      cont2 = TextEditingController(),
      cont3 = TextEditingController(),
      cont4 = TextEditingController(),
      cont5 = TextEditingController(),
      cont6 = TextEditingController(),
      cont7 = TextEditingController();

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
      formData[0] = prefs.get(GlobalVars.PREF_COMP_REG_NO);
      formData[1] = prefs.get(GlobalVars.PREF_COMP_NAME);
      formData[2] = prefs.get(GlobalVars.PREF_COMP_ADDRESS);
      formData[3] = prefs.get(GlobalVars.PREF_COMP_POSTCODE);
      formData[4] = prefs.get(GlobalVars.PREF_COMP_CITY);
      formData[5] = prefs.get(GlobalVars.PREF_COMP_STATE);
      formData[6] = prefs.get(GlobalVars.PREF_COMP_COUNTRY);
      formData[7] = prefs.get(GlobalVars.PREF_COMP_PHONE);

      // set for controller
      cont0.text = formData[0];
      cont1.text = formData[1];
      cont2.text = formData[2];
      cont3.text = formData[3];
      cont4.text = formData[4];
      cont5.text = formData[5];
      cont6.text = formData[6];
      cont7.text = formData[7];

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
              GlobalVars.getString("company_info"),
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
          // 0 - regNo
          MyFormField(
            controller: cont0,
            hintText: GlobalVars.getString("comp_reg_no"),
            validator: validateEmpty,
            onFieldSubmitted: focusForRegNo,
            onSaved: setFormData0,
          ),

          // 1 - name
          MyFormField(
            focusNode: nameFocus,
            hintText: GlobalVars.getString("comp_name"),
            controller: cont1,
            validator: validateEmpty,
            onFieldSubmitted: focusForName,
            onSaved: setFormData1,
          ),

          // 2 - address
          MyFormField(
            maxLines: 3,
            hintText: GlobalVars.getString("comp_address"),
            controller: cont2,
            focusNode: addressFocus,
            validator: validateEmpty,
            textInputAction: TextInputAction.newline,
            onSaved: setFormData2,
          ),

          // 3 - postcode
          MyFormField(
            controller: cont3,
            hintText: GlobalVars.getString("comp_postcode"),
            validator: validateEmpty,
            textInputType: TextInputType.number,
            onFieldSubmitted: focusForPostcode,
            onSaved: setFormData3,
          ),

          // 4 - city
          MyFormField(
            hintText: GlobalVars.getString("comp_city"),
            controller: cont4,
            focusNode: cityFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForCity,
            onSaved: setFormData4,
          ),

          // 5 - state
          MyFormField(
            controller: cont5,
            hintText: GlobalVars.getString("comp_state"),
            focusNode: stateFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForState,
            onSaved: setFormData5,
          ),

          // 6 - country
          MyFormField(
            controller: cont6,
            hintText: GlobalVars.getString("comp_country"),
            focusNode: countryFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForCountry,
            onSaved: setFormData6,
          ),

          // 7 - phone
          MyFormField(
            controller: cont7,
            hintText: GlobalVars.getString("comp_phone"),
            focusNode: phoneFocus,
            validator: validateEmpty,
            textInputType: TextInputType.phone,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData7,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  //form func
  void focusForRegNo(String value) {
    FocusScope.of(context).requestFocus(nameFocus);
  }

  void focusForName(String value) {
    FocusScope.of(context).requestFocus(addressFocus);
  }

  void focusForPostcode(String value) {
    FocusScope.of(context).requestFocus(cityFocus);
  }

  void focusForCity(String value) {
    FocusScope.of(context).requestFocus(stateFocus);
  }

  void focusForState(String value) {
    FocusScope.of(context).requestFocus(countryFocus);
  }

  void focusForCountry(String value) {
    FocusScope.of(context).requestFocus(phoneFocus);
  }

  //===== normal funcs
  void submitBtnOnClick(String val) {
    // validate
    if (formKey.currentState.validate()) {
      // save form data to var
      formKey.currentState.save();

      // save form data to pref
      preferences.setString(GlobalVars.PREF_COMP_REG_NO, formData[0]);
      preferences.setString(GlobalVars.PREF_COMP_NAME, formData[1]);
      preferences.setString(GlobalVars.PREF_COMP_ADDRESS, formData[2]);
      preferences.setString(GlobalVars.PREF_COMP_POSTCODE, formData[3]);
      preferences.setString(GlobalVars.PREF_COMP_CITY, formData[4]);
      preferences.setString(GlobalVars.PREF_COMP_STATE, formData[5]);
      preferences.setString(GlobalVars.PREF_COMP_COUNTRY, formData[6]);
      preferences.setString(GlobalVars.PREF_COMP_PHONE, formData[7]);

      // pass pword to next page
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => Reg4BankInfo()),
      );
    }
  }
}
