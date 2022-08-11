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

class BankInfo extends StatefulWidget {
  BuildContext ctx;

  BankInfo() : super();

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<BankInfo> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode2 = FocusNode();

  TextEditingController cont1 = TextEditingController();
  TextEditingController cont2 = TextEditingController();

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
      getBankInfo();

      // set for form
      cont1.text = prefs.get(GlobalVars.PREF_BANK_NAME);
      cont2.text = prefs.get(GlobalVars.PREF_BANK_ACC);

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
      title: GlobalVars.getString(GlobalVars.BANK_INFO),
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
          // 1 - bank name
          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString("bank_name"),
            validator: validateEmpty,
            onFieldSubmitted: focusFunc1,
            onSaved: setFormData1,
          ),

          // 2 - bank account number
          MyFormField(
            controller: cont2,
            hintText: GlobalVars.getString("bank_acc"),
            focusNode: focusNode2,
            validator: validateEmpty,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData2,
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  //form func
  void focusFunc1(String value) {
    FocusScope.of(context).requestFocus(focusNode2);
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
      preferences.setString(GlobalVars.PREF_BANK_NAME, formData[1]);
      preferences.setString(GlobalVars.PREF_BANK_ACC, formData[2]);

      // do post
      postUpdateBankInfo();
    }
  }

  //===== http funcs
  void getBankInfo() async {
    QueryOptions options = QueryOptions(
      document: queryBankInfo,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (!result.hasErrors) {
      respQuerySuccess(result.data);
    }
  }

  void respQuerySuccess(data) {
    // save resp data to pref
    var json = data["User"]["BankAccount"];
    preferences.setString(GlobalVars.PREF_BANK_NAME, json["bank_name"]);
    preferences.setString(
        GlobalVars.PREF_BANK_ACC, json["bank_account_number"]);

    setState(() {
      cont1.text = json["bank_name"];
      cont2.text = json["bank_account_number"];
    });
  }

  void postUpdateBankInfo() async {
    //===== define params to post
    // regInfo
    var bankName = preferences.get(GlobalVars.PREF_BANK_NAME);
    var bankAccNo = preferences.get(GlobalVars.PREF_BANK_ACC);

    MutationOptions options = MutationOptions(
      document: mutateBankInfo,
      variables: <String, dynamic>{
        // userInfo
        'bankName': bankName,
        'bankAccNo': bankAccNo,
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
