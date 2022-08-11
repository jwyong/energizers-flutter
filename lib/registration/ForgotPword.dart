import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/home/HomeTabs.dart';
import 'package:energizers/registration/ResetPword.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:energizers/widgets/PinCodeTextField.dart';
import 'package:energizers/widgets/RegActiLong.dart';
import 'package:energizers/widgets/RegActiShort.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// http posting
import 'package:http/http.dart' as http;

class ForgotPword extends StatefulWidget {
  static const String routeName = "/forgot_pword";

  @override
  State<StatefulWidget> createState() {
    return ForgotPwordState();
  }
}

class ForgotPwordState extends State<ForgotPword> {
  // basics
  SharedPreferences preferences;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController cont1 = TextEditingController();

  // for graphQL
  GraphQLClient graphQLClient = initGraphQL();

  // obs
  bool isSubmitBtnEnabled = true;
  bool isConfirmBtnEnabled = false;

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
          gotCloseBtn: true,
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: respHeight(20),
              ),
            ),

            // forgot password
            Text(
              GlobalVars.getString("forgot_pword"),
              style: TextStyle(fontSize: respSP(20), color: Colors.white),
              textAlign: TextAlign.center,
            ),

            // instructions
            regBodyTxt(GlobalVars.getString("forgot_inst"),
                EdgeInsets.symmetric(vertical: respHeight(20))),

            // email form
            form(),

            SizedBox(height: respHeight(10),),

            // submit btn
            MyRaisedBtn(
                GlobalVars.getString(GlobalVars.SUBMIT),
                isSubmitBtnEnabled
                    ? () {
                        submitBtnOnClick(null);
                      }
                    : null),

            Expanded(
              child: SizedBox(
                height: respHeight(20),
              ),
            ),

            // 6-digit inst
            regBodyTxt(GlobalVars.getString("forgot_inst_2"),
                EdgeInsets.symmetric(vertical: respHeight(10))),

            // 6-digit input
            pinCodeField(),

            // confirm btn
            MyRaisedBtn(
                GlobalVars.getString("confirm"),
                isConfirmBtnEnabled
                    ? () {
                        confirmBtnOnClick();
                      }
                    : null),
          ],
        ));
  }

  //===== widgets
  Widget form() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // email

          MyFormField(
            controller: cont1,
            hintText: GlobalVars.getString('email'),
            validator: validateEmail,
            onFieldSubmitted: submitBtnOnClick,
            onSaved: setFormData1,
            textInputType: TextInputType.emailAddress,
          )
        ],
      ),
    );
  }

  // for pincode
  String pincode;

  Widget pinCodeField() {
    return PinCodeTextField(
      maxLength: 6,
      maxWidth: respWidthPercent(70),
      pinCodeTextFieldLayoutType: PinCodeTextFieldLayoutType.AUTO_ADJUST_WIDTH,
      defaultBorderColor: Colors.white,
      highlight: true,
      hasTextBorderColor: Colors.white,
      pinBoxHeight: respWidthPercent(10),
      pinTextStyle: TextStyle(color: Colors.white),
      highlightColor: MyColours.lightBlue1,
      pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
      onTextChanged: (val) {
        // enable/disable btn as user input code
        setState(() {
          if (val.length == 6) {
            isConfirmBtnEnabled = true;
          } else {
            isConfirmBtnEnabled = false;
          }
        });
      },
      onDone: (val) {
        pincode = val;
        confirmBtnOnClick();
      },
    );
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

      // save form data to pref
      preferences.setString(GlobalVars.PREF_EMAIL, formData[1]);

      // close keyboard
      FocusScope.of(context).requestFocus(FocusNode());

      // do http post
      postForgotPword();
    }
  }

  // submit 6 digit code to reset pword
  void confirmBtnOnClick() {
    // validate
    if (pincode.length == 6) {
      // disable btn
      setState(() {
        isConfirmBtnEnabled = false;

        // do http post
        postResetPword(pincode);
      });
    }
  }

  //===== http funcs
  // submit email address to server
  void postForgotPword() async {
    //===== define params to post
    // regInfo
    var email = preferences.get(GlobalVars.PREF_EMAIL);

    MutationOptions options = MutationOptions(
      document: mutateForgotPword,
      variables: <String, dynamic>{
        'email': email,
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
      respForgotSuccess(result.data);
    }
  }

  void respForgotSuccess(data) {
    // toast user
    toastMsg(context, GlobalVars.getString(GlobalVars.FORGOT_PWORD_SUCCESS), duration: 5);
  }

  // submit 6-digit pword reset code to server
  void postResetPword(String pinCode) async {
    var email = preferences.get(GlobalVars.PREF_EMAIL);

    //===== define params to post
    QueryOptions options = QueryOptions(
      document: queryVeriResetPword,
      variables: <String, dynamic>{
        'email': email,
        'code': pinCode,
      },
    );

    final QueryResult result = await graphQLClient.query(options);

    // update UI
    setState(() {
      isConfirmBtnEnabled = true;
    });

    if (result.hasErrors) {
      respError(context, result);
    } else {
      respResetSuccess(result.data);
    }
  }

  void respResetSuccess(data) {
    // go to reset pword page
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ResetPword(data["verifyResetPasswordCode"])),
    );
  }
}
