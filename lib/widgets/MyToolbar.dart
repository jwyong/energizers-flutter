import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:flutter/material.dart';

AppBar MyToolbar(
    {@required BuildContext context,
    @required String title,
      Color backgroundColor,
    GlobalKey<ScaffoldState> scaffoldKey,
    bool isDrawerBtn = false}) {
  Widget leadBtn(Function onPressed, IconData icon) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.white,
      onPressed: onPressed,
    );
  }

  return AppBar(
    brightness: Brightness.dark,
    backgroundColor: backgroundColor?? MyColours.purple1,
    automaticallyImplyLeading: false,
    elevation: 0,
    title: Row(
      children: <Widget>[
        // drawer/back btn
        isDrawerBtn
            ? leadBtn(() {
                // drawer btn func - open drawer
                scaffoldKey.currentState.openDrawer();
              }, Icons.dehaze)
            : leadBtn(() {
                // back btn func - go back
                Navigator.pop(context);
              }, Icons.arrow_back_ios),

        // title
        Padding(
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.symmetric(horizontal: respWidth(20)),
        )
      ],
    ),
  );
}
