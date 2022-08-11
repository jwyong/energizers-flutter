import 'dart:convert';
import 'dart:developer';

import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/UplineList.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/widgets/AutoCompleteTextField.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/RegActiLong.dart';
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

import 'ForgotPword.dart';
import 'Reg2UserInfo.dart';

class Reg1 extends StatefulWidget {
  String searchError;

  Reg1() : super();

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Reg1> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode nricFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode pword1Focus = FocusNode();
  FocusNode pword2Focus = FocusNode();
  FocusNode searchFocus = FocusNode();

  TextEditingController cont0 = TextEditingController();
  TextEditingController cont1 = TextEditingController();
  TextEditingController cont2 = TextEditingController();
  TextEditingController cont3 = TextEditingController();
  TextEditingController cont4 = TextEditingController();

  // search autocomplete
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Upline>> searchKey = GlobalKey();

  List<Upline> uplines;

  // obs
  bool isBtnEnabled = true;
  bool isPwordObscured = true;
  bool isPword2Obscured = true;

  // for segmented controls
  int userTypeIndex = 2; // 2 = member, 1 = ambassador
  int memberTypeIndex = 1;

  // for graphQL
  GraphQLClient graphQLClient;

  @override
  void initState() {
    // init and post to server to get upline list
    graphQLClient = initGraphQL();
    getUplineList();

    super.initState();

    formData.clear();

    // set pref to form
    SharedPreferences.getInstance().then((prefs) {
      // set pref to fields
      userTypeIndex = prefs.getInt(GlobalVars.PREF_USER_TYPE) ?? 2;
      memberTypeIndex = prefs.getInt(GlobalVars.PREF_MEMBER_TYPE_INT) ?? 1;

      // set for form
      formData[1] = prefs.get(GlobalVars.PREF_EMAIL);
      formData[2] = prefs.get(GlobalVars.PREF_NRIC);
      formData[3] = prefs.get(GlobalVars.PREF_MOBILE);
      formData[4] = prefs.get(GlobalVars.PREF_USERNAME);

      // set for controller
      cont1.text = formData[1];
      cont2.text = formData[2];
      cont3.text = formData[3];
      cont4.text = formData[4];

      // search bar
      String uplineName = prefs.get(GlobalVars.PREF_UPLINE_NAME);
      String uplineCode = prefs.get(GlobalVars.PREF_UPLINE_CODE);
      String uplineID = prefs.get(GlobalVars.PREF_UPLINE_ID);
      if (uplineID == null) { // no upline in pref, set to energizers
        uplineName = "Energizers";
        uplineCode = "MP";
        uplineID = "01190001";

        // save to pref
        prefs.setString(GlobalVars.PREF_UPLINE_NAME, uplineName);
        prefs.setString(GlobalVars.PREF_UPLINE_CODE, uplineCode);
        prefs.setString(GlobalVars.PREF_UPLINE_ID, uplineID);
      }
      cont0.text = "$uplineName ($uplineCode$uplineID)";

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
        hideKeyboardOnly: true,
        gotCloseBtn: true,
        children: <Widget>[
          // registration
          Padding(
            padding: EdgeInsets.symmetric(vertical: respHeight(20)),
            child: Text(
              GlobalVars.getString("registration"),
              style: TextStyle(fontSize: respSP(20), color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          // user type (member/foreman)
          segContUserType({
            2: segContTxt2(GlobalVars.getString("member")),
            1: segContTxt2(GlobalVars.getString(GlobalVars.AMBASSADOR))
          }),

          // membership type (only for members)
          if (userTypeIndex == 2)
            segContMemberType({
              1: segContTxt4(GlobalVars.getString(GlobalVars.SPECIAL)),
              2: segContTxt4(GlobalVars.getString(GlobalVars.CLASSIC)),
              3: segContTxt4(GlobalVars.getString(GlobalVars.GOLD)),
              4: segContTxt4(GlobalVars.getString(GlobalVars.PLATINUM)),
            }),

          // form
          regForm(),

          // login btn
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
  Widget segContUserType(Map<int, Widget> widgetMap) {
    return CupertinoSegmentedControl(
        padding: EdgeInsets.symmetric(horizontal: 30),
        selectedColor: MyColours.purple1,
        borderColor: MyColours.purple1,
        unselectedColor: MyColours.grey1,
        children: widgetMap,
        onValueChanged: (val) {
          setState(() {
            userTypeIndex = val;
          });
        },
        groupValue: userTypeIndex);
  }

  Widget segContMemberType(Map<int, Widget> widgetMap) {
    return Padding(
      padding: EdgeInsets.only(top: respHeight(20)),
      child: CupertinoSegmentedControl(
          selectedColor: MyColours.purple1,
          borderColor: MyColours.purple1,
          unselectedColor: MyColours.grey1,
          children: widgetMap,
          onValueChanged: (val) {
            setState(() {
              memberTypeIndex = val;
            });
          },
          groupValue: memberTypeIndex),
    );
  }

  Widget regForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: respHeight(20),
          ),

          // 0 - autocomplete upline
          if (uplines != null)
            searchBar()
          else
            MyFormField(
              enabled: false,
              prefixIcon:
                  IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              hintText: GlobalVars.getString("searching_upline"),
            ),

          // 1 - email
          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString("email"),
            validator: validateEmail,
            onFieldSubmitted: focusForEmail,
            onSaved: setFormData1,
            textInputType: TextInputType.emailAddress,
          ),

          // 2 - NRIC/passport
          MyFormField(
            controller: cont2,
            hintText: GlobalVars.getString("nric_passport"),
            focusNode: nricFocus,
            onFieldSubmitted: focusForNric,
            onSaved: setFormData2,
          ),

          // 3 - mobile h/p
          MyFormField(
            controller: cont3,
            textInputType: TextInputType.phone,
            hintText: GlobalVars.getString("mobile"),
            focusNode: mobileFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForMobile,
            onSaved: setFormData3,
          ),

          // 4 - username
          MyFormField(
            controller: cont4,
            hintText: GlobalVars.getString("username"),
            focusNode: usernameFocus,
            validator: validateEmpty,
            onFieldSubmitted: focusForUsername,
            onSaved: setFormData4,
          ),

          // 5 - password
          MyFormField(
            hintText: GlobalVars.getString("password"),
            focusNode: pword1Focus,
            validator: validatePassword,
            onFieldSubmitted: focusForPword1,
            onSaved: setFormData5,
            obscureText: isPwordObscured,
            suffixIcon: showHidePwordBtn(),
          ),

          // 6 - confirm pword
          MyFormField(
            hintText: GlobalVars.getString("confirm_pword"),
            focusNode: pword2Focus,
            validator: confirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData6,
            obscureText: isPword2Obscured,
            suffixIcon: showHidePwordBtn2(),
          ),
        ],
      ),
    );
  }

  // searchbar setup
  Widget searchBar() {
    searchTextField = AutoCompleteTextField<Upline>(
      controller: cont0,
      focusNode: searchFocus,
      key: searchKey,
      suggestionsAmount: 5,
      suggestions: uplines,
      clearOnSubmit: false,
      itemBuilder: (context, item) {
        return searchResultsItem(item);
      },
      itemFilter: (item, query) {
        // search filter
        return item.userName.toLowerCase().contains(query.toLowerCase()) ||
            item.userID.toLowerCase().contains(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.userName.compareTo(b.userName);
      },
      itemSubmitted: (item) {
        // on results item clicked
        var uplineID = item.userID;
        var uplineName = item.userName;

        var memberShipCode = item.membershipCode;
        var memberShipID = item.memberShipID;

        // update UI
        setState(() {
          searchTextField.textField.controller.text = "$uplineName ($uplineID)";
        });

        // save to pref
        preferences.setString(GlobalVars.PREF_UPLINE_CODE, memberShipCode);
        preferences.setString(GlobalVars.PREF_UPLINE_ID, memberShipID);
        preferences.setString(GlobalVars.PREF_UPLINE_NAME, uplineName);
      },
      decoration: searchInputDeco(null),
    );

    return searchTextField;
  }

  // error code deco for updating search bar (inner widget)
  InputDecoration searchInputDeco(String errorStr) {
    return formFieldInputDeco(
      errorTxt: errorStr,
      hintText: GlobalVars.getString("refer_by_upline"),
      prefixIcon: IconButton(icon: Icon(Icons.search), onPressed: null),
    );
  }

  // autocomplete item
  Widget searchResultsItem(Upline item) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: respWidth(20), vertical: respHeight(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.userName,
            style: TextStyle(color: Colors.black, fontSize: respSP(16)),
          ),
          Text(
            item.userID,
            style: TextStyle(color: MyColours.grey8, fontSize: respSP(14)),
          ),
          Divider()
        ],
      ),
    );
  }

  IconButton showHidePwordBtn() {
    return iconBtn(Icon(isPwordObscured ? Icons.remove_red_eye : Icons.lock),
        () {
      setState(() {
        isPwordObscured = !isPwordObscured;
      });
    });
  }

  IconButton showHidePwordBtn2() {
    return iconBtn(Icon(isPword2Obscured ? Icons.remove_red_eye : Icons.lock),
        () {
      setState(() {
        isPword2Obscured = !isPword2Obscured;
      });
    });
  }

  //form func
  void focusForEmail(String value) {
    FocusScope.of(context).requestFocus(nricFocus);
  }

  void focusForNric(String value) {
    FocusScope.of(context).requestFocus(mobileFocus);
  }

  void focusForMobile(String value) {
    FocusScope.of(context).requestFocus(usernameFocus);
  }

  void focusForUsername(String value) {
    FocusScope.of(context).requestFocus(pword1Focus);
  }

  void focusForPword1(String value) {
    FocusScope.of(context).requestFocus(pword2Focus);
  }

  //===== normal funcs
  void submitBtnOnClick(String val) {
    // validate search field first
    if (cont0.text == null || cont0.text.isEmpty) {
      // no upline id, show error
      searchTextField.updateDecoration(
          decoration: searchInputDeco(GlobalVars.getString("no_uplines")));

      return;
    } else {
      searchTextField.updateDecoration(decoration: searchInputDeco(null));
    }

    // validate
    if (formKey.currentState.validate()) {
      // save form data to var
      formKey.currentState.save();

      // save form data to pref
      preferences.setString(GlobalVars.PREF_EMAIL, formData[1]);
      preferences.setString(GlobalVars.PREF_NRIC, formData[2]);
      preferences.setString(GlobalVars.PREF_MOBILE, formData[3]);
      preferences.setString(GlobalVars.PREF_USERNAME, formData[4]);
      preferences.setString(GlobalVars.PREF_PWORD_TEMP, formData[5]);
      preferences.setInt(GlobalVars.PREF_USER_TYPE, userTypeIndex);
      preferences.setInt(GlobalVars.PREF_MEMBER_TYPE_INT, memberTypeIndex);

      // pass pword to next page
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => Reg2UserInfo()),
      );
    }
  }

  //===== http funcs
  void getUplineList() async {
    QueryOptions options = QueryOptions(
      document: getUplines,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (result.hasErrors) {
      respError(context, result);
    } else {
      respSuccess(result.data);
    }
  }

  void respSuccess(data) {
    setState(() {
      uplines = UplineList.fromJson(data).uplineList;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
