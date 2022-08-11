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
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// http posting
import 'package:http/http.dart' as http;

class CompInfo extends StatefulWidget {
  BuildContext ctx;

  CompInfo() : super();

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<CompInfo> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  FocusNode focusNode7 = FocusNode();

  TextEditingController cont0 = TextEditingController();
  TextEditingController cont1 = TextEditingController();
  TextEditingController cont2 = TextEditingController();
  TextEditingController cont3 = TextEditingController();
  TextEditingController cont4 = TextEditingController();
  TextEditingController cont5 = TextEditingController();
  TextEditingController cont6 = TextEditingController();
  TextEditingController cont7 = TextEditingController();

  // obs
  bool isBtnEnabled = true;

  // for graphQL
  GraphQLClient graphQLClient;

  @override
  void initState() {
    super.initState();

    formData.clear();

    // set pref to form
    SharedPreferences.getInstance().then((prefs) {
      // init qr with auth token
      graphQLClient = initGraphQL(
          accessToken: prefs.getString(GlobalVars.PREF_ACCESS_TOKEN));
      getCompInfo();

      // set for form
      cont0.text = prefs.get(GlobalVars.PREF_COMP_REG_NO);
      cont1.text = prefs.get(GlobalVars.PREF_COMP_NAME);
      cont2.text = prefs.get(GlobalVars.PREF_COMP_ADDRESS);
      cont3.text = prefs.get(GlobalVars.PREF_COMP_POSTCODE);
      cont4.text = prefs.get(GlobalVars.PREF_COMP_CITY);
      cont5.text = prefs.get(GlobalVars.PREF_COMP_STATE);
      cont6.text = prefs.get(GlobalVars.PREF_COMP_COUNTRY);
      cont7.text = prefs.get(GlobalVars.PREF_COMP_PHONE);

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.ctx = context;
    initScreenUtil(context);

    return ScrollActiLong(
      title: GlobalVars.getString(GlobalVars.COMP_INFO),
      children: <Widget>[
        // form
        form(),

        // update btn
        SizedBox(
          height: respHeight(25),
        ),

        MyRaisedBtn(
            GlobalVars.getString("update"),
            isBtnEnabled
                ? () {
                    submitBtnOnClick(null);
                  }
                : null),
      ],
    );
  }

  //===== widgets
  Widget form() {
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
            onFieldSubmitted: focusFunc0,
            onSaved: setFormData0,
          ),

          // 1 - comp name
          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString("comp_name"),
            validator: validateEmpty,
            focusNode: focusNode1,
            onFieldSubmitted: focusFunc1,
            onSaved: setFormData1,
          ),

          // 2 - comp address
          MyFormField(
            controller: cont2,
            hintText: GlobalVars.getString("comp_address"),
            focusNode: focusNode2,
            maxLines: 3,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc2,
            onSaved: setFormData2,
          ),

          // 3 - comp postcode
          MyFormField(
            controller: cont3,
            textInputType: TextInputType.number,
            hintText: GlobalVars.getString("comp_postcode"),
            focusNode: focusNode3,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc3,
            onSaved: setFormData3,
          ),

          // 4 - comp city
          MyFormField(
            controller: cont4,
            hintText: GlobalVars.getString("comp_city"),
            focusNode: focusNode4,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc4,
            onSaved: setFormData4,
          ),

          // 5 - comp state
          MyFormField(
            controller: cont5,
            hintText: GlobalVars.getString("comp_state"),
            focusNode: focusNode5,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc5,
            onSaved: setFormData5,
          ),

          // 6 - comp country
          MyFormField(
            controller: cont6,
            hintText: GlobalVars.getString("comp_country"),
            focusNode: focusNode6,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc6,
            onSaved: setFormData6,
          ),

          // 7 - comp mobile
          MyFormField(
            controller: cont7,
            hintText: GlobalVars.getString("comp_phone"),
            focusNode: focusNode7,
            validator: validateEmpty,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: submitBtnOnClick,
            textInputType: TextInputType.phone,
            onSaved: setFormData7,
          ),
        ],
      ),
    );
  }

  //form func
  void focusFunc0(String value) {
    FocusScope.of(context).requestFocus(focusNode1);
  }

  void focusFunc1(String value) {
    FocusScope.of(context).requestFocus(focusNode2);
  }

  void focusFunc2(String value) {
    FocusScope.of(context).requestFocus(focusNode3);
  }

  void focusFunc3(String value) {
    FocusScope.of(context).requestFocus(focusNode4);
  }

  void focusFunc4(String value) {
    FocusScope.of(context).requestFocus(focusNode5);
  }

  void focusFunc5(String value) {
    FocusScope.of(context).requestFocus(focusNode6);
  }

  void focusFunc6(String value) {
    FocusScope.of(context).requestFocus(focusNode7);
  }

  //===== normal funcs
  void submitBtnOnClick(String val) {
    // validate
    if (formKey.currentState.validate()) {
      // updateUI
      setState(() {
        isBtnEnabled = false;
      });

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

      // do post
      postUpdateCompInfo();
    }
  }

  //===== http funcs
  void getCompInfo() async {
    QueryOptions options = QueryOptions(
      document: queryCompInfo,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (!result.hasErrors) {
      respQuerySuccess(result.data);
    }
  }

  void respQuerySuccess(data) {
    // save resp data to pref
    var json = data["User"]["CompanyInfo"];
    preferences.setString(GlobalVars.PREF_COMP_REG_NO, json["company_registration_number"]);
    preferences.setString(GlobalVars.PREF_COMP_NAME, json["company_name"]);
    preferences.setString(GlobalVars.PREF_COMP_ADDRESS, json["company_address"]);
    preferences.setString(GlobalVars.PREF_COMP_POSTCODE, json["company_postcode"]);
    preferences.setString(GlobalVars.PREF_COMP_CITY, json["company_city"]);
    preferences.setString(GlobalVars.PREF_COMP_STATE, json["company_state"]);
    preferences.setString(GlobalVars.PREF_COMP_COUNTRY, json["company_country"]);
    preferences.setString(GlobalVars.PREF_COMP_PHONE, json["company_phone"]);

    setState(() {
      cont0.text = json["company_registration_number"];
      cont1.text = json["company_name"];
      cont2.text = json["company_address"];
      cont3.text = json["company_postcode"];
      cont4.text = json["company_city"];
      cont5.text = json["company_state"];
      cont6.text = json["company_country"];
      cont7.text = json["company_phone"];
    });
  }

  void postUpdateCompInfo() async {
    //===== define params to post
    // regInfo
    var compRegNo = preferences.get(GlobalVars.PREF_COMP_REG_NO);
    var compName = preferences.get(GlobalVars.PREF_COMP_NAME);
    var address = preferences.get(GlobalVars.PREF_COMP_ADDRESS);
    var postCode = preferences.get(GlobalVars.PREF_COMP_POSTCODE);
    var city = preferences.get(GlobalVars.PREF_COMP_CITY);
    var state = preferences.get(GlobalVars.PREF_COMP_STATE);
    var country = preferences.get(GlobalVars.PREF_COMP_COUNTRY);
    var phone = preferences.get(GlobalVars.PREF_COMP_PHONE);

    MutationOptions options = MutationOptions(
      document: mutateCompInfo,
      variables: <String, dynamic>{
        // userInfo
        'regNo': compRegNo,
        'name': compName,
        'address': address,
        'postcode': postCode,
        'city': city,
        'state': state,
        'country': country,
        'phone': phone,
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
      respSuccess(null);
    }
  }

  void respSuccess(data) {
    // toast success
    toastMsg(widget.ctx, GlobalVars.getString("update_success"));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
