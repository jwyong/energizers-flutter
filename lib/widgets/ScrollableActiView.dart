import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:flutter/material.dart';

class ScrollableActiView extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  ScrollableActiView({Widget child, EdgeInsets padding})
      : child = child,
        padding = padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
                child: Padding(
              padding: padding?? EdgeInsets.all(0),
              child: this.child,
            )),
          ),
        );
      })),
    );
  }
}
