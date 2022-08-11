import 'dart:async';
import 'dart:developer';

import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/RegRespModel.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/home/HomeTabs.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/RegActiShort.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:graphql/client.dart';
import 'package:graphql/internal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// http posting
import 'package:http/http.dart' as http;

import 'ForgotPword.dart';
import 'Login.dart';
import 'Reg1.dart';

class Reg4BankInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Reg4BankInfo> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  TextEditingController cont1 = TextEditingController(),
      cont2 = TextEditingController();

  // obs
  bool isBtnEnabled = true;

  // for graphQL
  GraphQLClient graphQLClient;

  @override
  void initState() {
    graphQLClient = initGraphQL();

    super.initState();

    formData.clear();

    SharedPreferences.getInstance().then((prefs) {
      // set pref to fields
      formData[1] = prefs.get(GlobalVars.PREF_BANK_NAME);
      formData[2] = prefs.get(GlobalVars.PREF_BANK_ACC);

      // set for controller
      cont1.text = formData[1];
      cont2.text = formData[2];

      setState(() => preferences = prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtil(context);

    return Scaffold(
        backgroundColor: Colors.grey,
        body: RegActiShort(
          gotCloseBtn: true,
          children: <Widget>[
            Expanded(child: Text("")),

            // Bank Account
            Padding(
              padding: EdgeInsets.symmetric(vertical: respHeight(20)),
              child: Text(
                GlobalVars.getString("bank_acc"),
                style: TextStyle(fontSize: respSP(20), color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

            // form
            regForm(),

            // submit btn
            SizedBox(
              height: respHeight(25),
            ),
            MyRaisedBtn(
                GlobalVars.getString(GlobalVars.SUBMIT),
                isBtnEnabled
                    ? () {
                  submitBtnOnClick(null);
                }
                    : null),

            // Any cash...
            Padding(
                padding: EdgeInsets.only(top: respHeight(8)),
                child: Center(
                    child: regBodyTxt(GlobalVars.getString("bank_desc"),
                        EdgeInsets.symmetric(vertical: respHeight(10))))),
          ],
        ));
  }

  //===== widgets
  Widget regForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1 - bank name
          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString("bank_name"),
            validator: validateEmpty,
            onFieldSubmitted: goToNextField,
            onSaved: setFormData1,
          ),

          // bank account
          MyFormField(
            hintText: GlobalVars.getString("bank_acc"),
            focusNode: focusNode,
            controller: cont2,
            validator: validateEmpty,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData2,
            textInputType: TextInputType.number,
          )
        ],
      ),
    );
  }

  Widget btm2Logos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        img('assets/logo/beltroad_logo.png',
            MediaQuery
                .of(context)
                .size
                .width / 3, null),
        img('assets/logo/beltroad_logo.png',
            MediaQuery
                .of(context)
                .size
                .width / 3, null)
      ],
    );
  }

  Widget img(String imgPath, double width, double height) {
    return Image(
      width: width,
      height: height,
      image: AssetImage(imgPath),
    );
  }

  // forgot password | create account
  Widget btmTextItem(String label, Function onClickFunc) {
    return InkWell(
      onTap: onClickFunc,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  //form func
  void goToNextField(String value) {
    FocusScope.of(context).requestFocus(focusNode);
  }


  //===== normal funcs
  void submitBtnOnClick(String val) {
    // validate
    if (formKey.currentState.validate()) {
      // disable btn
      setState(() {
        isBtnEnabled = false;
      });

      // save form data to var
      formKey.currentState.save();

      // save form data to pref
      preferences.setString(GlobalVars.PREF_BANK_NAME, formData[1]);
      preferences.setString(GlobalVars.PREF_BANK_ACC, formData[2]);

      // do http post
      postRegister();
    }
  }

  //===== http funcs
  void postRegister() async {
    //===== define params to post
    // regInfo
    var uplineCode = preferences.get(GlobalVars.PREF_UPLINE_CODE);
    var uplineID = preferences.get(GlobalVars.PREF_UPLINE_ID);
    var userType =
        "${preferences.getInt(GlobalVars.PREF_USER_TYPE)},${preferences.getInt(
        GlobalVars.PREF_MEMBER_TYPE_INT)}";
    var email = preferences.get(GlobalVars.PREF_EMAIL);
    var nric = preferences.get(GlobalVars.PREF_NRIC);
    var phone = preferences.get(GlobalVars.PREF_MOBILE);
    var userName = preferences.get(GlobalVars.PREF_USERNAME);
    var pword = preferences.get(GlobalVars.PREF_PWORD_TEMP);

    // userInfo
    var address = preferences.get(GlobalVars.PREF_ADDRESS);
    var postCode = preferences.get(GlobalVars.PREF_POSTCODE);
    var city = preferences.get(GlobalVars.PREF_CITY);
    var state = preferences.get(GlobalVars.PREF_STATE);
    var country = preferences.get(GlobalVars.PREF_COUNTRY);

    // compInfo
    var compName = preferences.get(GlobalVars.PREF_COMP_NAME);
    var compRegNo = preferences.get(GlobalVars.PREF_COMP_REG_NO);
    var compAddress = preferences.get(GlobalVars.PREF_COMP_ADDRESS);
    var compPostcode = preferences.get(GlobalVars.PREF_COMP_POSTCODE);
    var compCity = preferences.get(GlobalVars.PREF_COMP_CITY);
    var compState = preferences.get(GlobalVars.PREF_COMP_STATE);
    var compCountry = preferences.get(GlobalVars.PREF_COMP_COUNTRY);
    var compPhone = preferences.get(GlobalVars.PREF_COMP_PHONE);

    // bankInfo
    var bankName = preferences.get(GlobalVars.PREF_BANK_NAME);
    var bankAccNo = preferences.get(GlobalVars.PREF_BANK_ACC);

    log("${GlobalVars.TAG}, Reg4BankInfo, _State.postRegister: pword = $pword");

    MutationOptions options = MutationOptions(
      document: mutateRegister,
      variables: <String, dynamic>{
        // regInfo
        'uplineCode': uplineCode,
        'uplineId': uplineID,
        'userType': userType,
        'email': email,
        'nric': nric,
        'phone': phone,
        'userName': userName,
        'pword': pword,

        // userInfo
        'address': address,
        'postcode': postCode,
        'city': city,
        'state': state,
        'country': country,

        // compInfo
        'compName': compName,
        'compRegNo': compRegNo,
        'compAddress': compAddress,
        'compPostcode': compPostcode,
        'compCity': compCity,
        'compState': compState,
        'compCountry': compCountry,
        'compPhone': compPhone,

        // bankInfo
        'bankName': bankName,
        'bankAccNo': bankAccNo
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);

    // update UI
    setState(() {
      isBtnEnabled = true;
    });
    if (result.hasErrors) {
      respError(context, result);
    } else {
      respSuccess(result.data);
    }
  }

  void respSuccess(data) {
    // get json resp
    RegRespModel respModel = RegRespModel.fromJson(data);

    // update UI
    setState(() {
      isBtnEnabled = true;
    });

    // save dets to pref
    preferences.setString(GlobalVars.PREF_PWORD_TEMP, "");

    // toast msg and finish (need to be approved by admin first)
    toastMsg(context, GlobalVars.getString(GlobalVars.REG_SUCCESS_APPROVE),
        duration: 5);


    // go to login page after 5 secs
    goToLoginDelay();
  }

  Future<void> goToLoginDelay() async {
    await new Future.delayed(const Duration(seconds: 5));

    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
