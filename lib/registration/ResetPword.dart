import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/registration/Login.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:energizers/widgets/RegActiShort.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

// http posting
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResetPword extends StatefulWidget {
  String authToken;
  ResetPword(this.authToken);

  @override
  State<StatefulWidget> createState() {
    return ResetPwordState();
  }
}

class ResetPwordState extends State<ResetPword> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController cont1 = TextEditingController();
  FocusNode focusNode = FocusNode();

  // for graphQL
  GraphQLClient graphQLClient;

  // obs
  bool isSubmitBtnEnabled = true;
  bool isPword1Obscured = true;
  bool isPword2Obscured = true;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      graphQLClient = initGraphQL(
          accessToken: widget.authToken);

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
      body: RegActiShort(gotCloseBtn: true, children: <Widget>[
        SizedBox(
          height: respHeight(20),
        ),

        // reset pword
        Text(
          GlobalVars.getString(GlobalVars.RESET_PWORD_TITLE),
          style: TextStyle(fontSize: respSP(20), color: Colors.white),
          textAlign: TextAlign.center,
        ),

        Expanded(
          child: SizedBox(
            height: respHeight(20),
          ),
        ),

        // instructions
        regBodyTxt(GlobalVars.getString("reset_inst"),
            EdgeInsets.symmetric(vertical: respHeight(10)),
            textAlignment: TextAlign.center),

        // form
        form(),

//        Expanded(
//          child:
          SizedBox(
            height: respHeight(20),
          ),
//        ),

        // submit btn
        MyRaisedBtn(
            GlobalVars.getString(GlobalVars.SUBMIT),
            isSubmitBtnEnabled
                ? () {
                    submitBtnOnClick(null);
                  }
                : null),
      ]),
    );
  }

  //===== widgets
  Widget form() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          // pword
          MyFormField(
            hintText: GlobalVars.getString("password"),
            validator: validatePassword,
            onFieldSubmitted: goToNextField,
            onSaved: setFormData1,
            obscureText: isPword1Obscured,
            suffixIcon: showHidePwordBtn1(),
          ),

          // confirm pword
          MyFormField(
            hintText: GlobalVars.getString("confirm_pword"),
            focusNode: focusNode,
            validator: confirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData2,
            obscureText: isPword2Obscured,
            suffixIcon: showHidePwordBtn2(),
          )
        ],
      ),
    );
  }

  IconButton showHidePwordBtn1() {
    return iconBtn(Icon(isPword1Obscured ? Icons.remove_red_eye : Icons.lock),
            () {
          setState(() {
            isPword1Obscured = !isPword1Obscured;
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
  void goToNextField(String value) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  //===== normal funcs
  // submit email address to get 6 digit code
  void submitBtnOnClick(String _val) {
    // validate
    if (formKey.currentState.validate()) {
      // disable btn
      setState(() {
        isSubmitBtnEnabled = false;
      });

      // save form data to var
      formKey.currentState.save();

      // do http post
      postChangePword();
    }
  }

  //===== http funcs
  // set new pword
  void postChangePword() async {
    //===== define params to post
    MutationOptions options = MutationOptions(
      document: mutateResetPword,
      variables: <String, dynamic>{
        'password': formData[1],
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);

    // update UI
    setState(() {
      isSubmitBtnEnabled = true;
    });

    if (result.hasErrors) {
      respError(context, result);
    } else {
      respSuccess(result.data);
    }
  }

  void respSuccess(data) {
    // toast user
    toastMsg(context, GlobalVars.getString(GlobalVars.RESET_PWORD_SUCCESS), duration: 4);

    goToLoginDelay();
  }

  // go to login after 5 secs
  Future<void> goToLoginDelay() async {
    await new Future.delayed(const Duration(seconds: 4));

    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false);
  }
}
