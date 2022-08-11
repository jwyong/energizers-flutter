import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:flutter/material.dart';

class MyRaisedBtn extends StatelessWidget {
  String label;
  VoidCallback onPressed;
  bool isBtnEnabled;

  MyRaisedBtn(this.label, this.onPressed, {bool isBtnEnabled})
      : isBtnEnabled = isBtnEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: respWidthPercent(80),
      child:
      RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        disabledTextColor: MyColours.white50a,
        disabledColor: MyColours.purple1a70,
        padding: EdgeInsets.symmetric(vertical: respHeight(15)),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: respSP(18)),
        ),
        onPressed: onPressed,
        color: MyColours.purple1,
      ),
//    RaisedButton.icon(onPressed: null, icon: null, label: null)
    );
  }
}
