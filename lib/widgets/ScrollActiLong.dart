import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels;

import 'MyText.dart';

class ScrollActiLong extends StatelessWidget {
  final Color toolbarBg;
  final String title;
  final List<Widget> children;
  final bool hideKeyboardOnly;
  final Function gestureFunc;
  final EdgeInsetsGeometry padding;

  ScrollActiLong({
    @required List<Widget> children,
    @required String title,
    Function gestureFunc,
    EdgeInsetsGeometry padding,
    Color toolbarBg,
    bool hideKeyboardOnly = false,
  })  : children = children,
        toolbarBg = toolbarBg,
        title = title,
        padding = padding,
        hideKeyboardOnly = hideKeyboardOnly,
        gestureFunc = gestureFunc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (hideKeyboardOnly) {
            // only hide keyboard
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          } else {
            // hide keyboard AND lose focus
            FocusScope.of(context).requestFocus(FocusNode());
          }

          // additional functions if got
          if (gestureFunc != null) {
            gestureFunc();
          }
        },
        child: Scaffold(
            backgroundColor: toolbarBg ?? MyColours.white,
            appBar: AppBar(
              title: homeTabsHeading(title),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: padding ??
                    EdgeInsets.symmetric(
                        horizontal: respWidth(30), vertical: respHeight(20)),
                child: // main content
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                      // dynamic content
                      for (var widget in this.children) widget,
                    ]),
              ),
            )));
  }
}
