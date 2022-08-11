import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/LoginRespModel.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/home/HomeTabs.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/RegActiShort.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// http posting
import 'package:http/http.dart' as http;

import 'ForgotPword.dart';
import 'Reg1.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  TextEditingController cont1 = TextEditingController();

  // obs
  bool isBtnEnabled = true;
  bool isPwordObscured = true;

  // for graphQL
  GraphQLClient graphQLClient = initGraphQL();

  @override
  void initState() {
    super.initState();

    formData.clear();

    SharedPreferences.getInstance().then((prefs) {
      // set pref to fields
      formData[1] = prefs.get(GlobalVars.PREF_EMAIL);
      cont1.text = formData[1];

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtil(context);

    return Scaffold(
        backgroundColor: Colors.grey,
        body: RegActiShort(
          children: <Widget>[
            // good morning
            Padding(
              padding: EdgeInsets.symmetric(vertical: respHeight(20)),
              child: Text(
                getGreetingStr(),
                style: TextStyle(fontSize: respSP(20), color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(child: Text("")),

            // form
            loginForm(),

            // login btn
            SizedBox(
              height: respHeight(25),
            ),
            MyRaisedBtn(
                GlobalVars.getString("login"),
                isBtnEnabled
                    ? () {
                        submitBtnOnClick(null);
                      }
                    : null),

            // forgot pword | create account
            Padding(
                padding: EdgeInsets.only(top: respHeight(8)),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      btmTextItem(GlobalVars.getString("forgot_pword"),
                          forgetPwordOnClick),
                      btmTextItem(" | ", null),
                      btmTextItem(GlobalVars.getString("create_account"),
                          createAccOnClick)
                    ],
                  ),
                )),
          ],
//        ))
        ));
  }

  //===== widgets
  Widget loginForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1 - email
          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString("email"),
            validator: validateEmail,
            onFieldSubmitted: goToNextField,
            onSaved: setFormData1,
            textInputType: TextInputType.emailAddress,
          ),

          // 2 - password
          MyFormField(
            hintText: GlobalVars.getString("password"),
            focusNode: focusNode,
            validator: validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: submitBtnOnClick,
            obscureText: isPwordObscured,
            onSaved: setFormData2,
            suffixIcon: showHidePwordBtn(),
          )
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

  Widget btm2Logos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        img('assets/logo/beltroad_logo.png',
            MediaQuery.of(context).size.width / 3, null),
        img('assets/logo/beltroad_logo.png',
            MediaQuery.of(context).size.width / 3, null)
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
      formKey.currentState.save();

      // save form data to pref
      preferences.setString(GlobalVars.PREF_EMAIL, formData[1]);

      // do http post
      postLogin();
    }
  }

  void forgetPwordOnClick() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ForgotPword()),
    );
  }

  void createAccOnClick() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => Reg1()),
    );
  }

  // get hour from a timestamp
  String getGreetingStr() {
    var hourFormat = DateFormat("H");
    int hour = int.parse(hourFormat.format(DateTime.now()));

    if (hour < 5) {
      // evening
      return GlobalVars.getString(GlobalVars.GOOD_EVENING);
    } else if (hour < 12) {
      // morning
      return GlobalVars.getString(GlobalVars.GOOD_MORNING);
    } else if (hour < 19) {
      // afternoon
      return GlobalVars.getString(GlobalVars.GOOD_AFTERNOON);
    } else {
      return GlobalVars.getString(GlobalVars.GOOD_EVENING);
    }
  }

  //===== http funcs
  void postLogin() async {
    print("${GlobalVars.TAG}, Login, _LoginState.postLogin: pword = ${formData[2]}");

    //===== define params to post
    // regInfo
    var email = preferences.get(GlobalVars.PREF_EMAIL);

    MutationOptions options = MutationOptions(
      document: mutateLogin,
      variables: <String, dynamic>{
        'email': email,
        'pass': formData[2],
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
    LoginRespModel respModel = LoginRespModel.fromJson(data);

    // save resp data to pref
    preferences.setString(GlobalVars.PREF_USERNAME, respModel.userName);
    preferences.setString(GlobalVars.PREF_ACCESS_TOKEN, respModel.accessToken);
    preferences.setInt(GlobalVars.PREF_USER_TYPE, respModel.userTypeInt);

    // go to homeTabs (logged in)
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => HomeTabs()),
        (Route<dynamic> route) => false);
  }
}
