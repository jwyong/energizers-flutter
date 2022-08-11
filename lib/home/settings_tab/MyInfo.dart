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

class MyInfo extends StatefulWidget {
  BuildContext ctx;

  MyInfo() : super();

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<MyInfo> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  FocusNode focusNode7 = FocusNode();

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
      getMyInfo();

      // set for form
      cont1.text = prefs.get(GlobalVars.PREF_USERNAME);
      cont2.text = prefs.get(GlobalVars.PREF_ADDRESS);
      cont3.text = prefs.get(GlobalVars.PREF_POSTCODE);
      cont4.text = prefs.get(GlobalVars.PREF_CITY);
      cont5.text = prefs.get(GlobalVars.PREF_STATE);
      cont6.text = prefs.get(GlobalVars.PREF_COUNTRY);
      cont7.text = prefs.get(GlobalVars.PREF_MOBILE);

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
      title: GlobalVars.getString(GlobalVars.USER_INFO),
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
          // 1 - username
          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString("username"),
            validator: validateEmpty,
            onFieldSubmitted: focusFunc1,
            onSaved: setFormData1,
          ),

          // 2 - address
          MyFormField(
            controller: cont2,
            hintText: GlobalVars.getString("address"),
            focusNode: focusNode2,
            maxLines: 3,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc2,
            onSaved: setFormData2,
          ),

          // 3 - postcode
          MyFormField(
            controller: cont3,
            textInputType: TextInputType.number,
            hintText: GlobalVars.getString("postcode"),
            focusNode: focusNode3,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc3,
            onSaved: setFormData3,
          ),

          // 4 - city
          MyFormField(
            controller: cont4,
            hintText: GlobalVars.getString("city"),
            focusNode: focusNode4,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc4,
            onSaved: setFormData4,
          ),

          // 5 - state
          MyFormField(
            controller: cont5,
            hintText: GlobalVars.getString("state"),
            focusNode: focusNode5,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc5,
            onSaved: setFormData5,
          ),

          // 6 - country
          MyFormField(
            controller: cont6,
            hintText: GlobalVars.getString("country"),
            focusNode: focusNode6,
            validator: validateEmpty,
            onFieldSubmitted: focusFunc6,
            onSaved: setFormData6,
          ),

          // 7 - mobile
          MyFormField(
            controller: cont7,
            hintText: GlobalVars.getString("mobile"),
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
      preferences.setString(GlobalVars.PREF_USERNAME, formData[1]);
      preferences.setString(GlobalVars.PREF_ADDRESS, formData[2]);
      preferences.setString(GlobalVars.PREF_POSTCODE, formData[3]);
      preferences.setString(GlobalVars.PREF_CITY, formData[4]);
      preferences.setString(GlobalVars.PREF_STATE, formData[5]);
      preferences.setString(GlobalVars.PREF_COUNTRY, formData[6]);
      preferences.setString(GlobalVars.PREF_MOBILE, formData[7]);

      // do post
      postUpdateMyInfo();
    }
  }

  //===== http funcs
  void getMyInfo() async {
    QueryOptions options = QueryOptions(
      document: queryMyInfo,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (!result.hasErrors) {
      respQuerySuccess(result.data);
    }
  }

  void respQuerySuccess(data) {
    // save resp data to pref
    var json = data["User"];
    preferences.setString(GlobalVars.PREF_USERNAME, json["name"]);
    preferences.setString(GlobalVars.PREF_ADDRESS, json["address"]);
    preferences.setString(GlobalVars.PREF_POSTCODE, json["postcode"]);
    preferences.setString(GlobalVars.PREF_CITY, json["city"]);
    preferences.setString(GlobalVars.PREF_STATE, json["state"]);
    preferences.setString(GlobalVars.PREF_COUNTRY, json["country"]);
    preferences.setString(GlobalVars.PREF_MOBILE, json["phone_number"]);

    setState(() {
      cont1.text = json["name"];
      cont2.text = json["address"];
      cont3.text = json["postcode"];
      cont4.text = json["city"];
      cont5.text = json["state"];
      cont6.text = json["country"];
      cont7.text = json["phone_number"];
    });
  }

  void postUpdateMyInfo() async {
    //===== define params to post
    // regInfo
    var userName = preferences.get(GlobalVars.PREF_USERNAME);
    var address = preferences.get(GlobalVars.PREF_ADDRESS);
    var postCode = preferences.get(GlobalVars.PREF_POSTCODE);
    var city = preferences.get(GlobalVars.PREF_CITY);
    var state = preferences.get(GlobalVars.PREF_STATE);
    var country = preferences.get(GlobalVars.PREF_COUNTRY);
    var phone = preferences.get(GlobalVars.PREF_MOBILE);

    MutationOptions options = MutationOptions(
      document: mutateMyInfo,
      variables: <String, dynamic>{
        // userInfo
        'userName': userName,
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
