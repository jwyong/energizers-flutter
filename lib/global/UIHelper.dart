import 'package:energizers/widgets/MyAlertDialog2Btns.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'GlobalVars.dart';

// posting error handling
void respError(BuildContext context, QueryResult result) {
  String errorCode = result.errors[0].message;

  print("${GlobalVars.TAG} : respError result = ${result.errors}");

  // toast raw error for now
  toastMsg(context, errorCode);
}

void toastMsg(BuildContext context, String msg,
    {String title,
    int duration,
    Function onComplete,
    FlushbarPosition position}) {
  Flushbar(
    flushbarPosition: position ?? FlushbarPosition.BOTTOM,
    title: title,
    message: msg,
    duration: Duration(seconds: duration ?? 2),
  )..show(context).then((val) {
      if (onComplete != null) {
        onComplete();
      }
    });
}

void showAlert2Btns(BuildContext context,
    {String title,
    @required String desc,
    String positiveTxt,
    @required Function positiveFunc,
    String negativeTxt,
    Function negativeFunc}) {
  showMyDialog(
      context: context,
      builder: (BuildContext ctx) {
        return MyAlertDialog2Btns(
          title: title,
          description: desc,
          positiveBtnText: positiveTxt,
          positiveFunc: positiveFunc,
          negativeBtnText: negativeTxt,
          negativeFunc: negativeFunc,
        );
      });
}
