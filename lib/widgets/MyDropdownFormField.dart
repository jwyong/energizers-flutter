import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:flutter/material.dart';
import 'package:energizers/global/MyColours.dart';

class MyDropdownFormField extends StatefulWidget {
  final List<DropdownMenuItem<String>> items;
  final String hintText;
  final String initialText;
  final bool isExpanded;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;

  MyDropdownFormField({
    @required List<DropdownMenuItem<String>> items,
    @required String hintText,
    String initialText,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
    bool isExpanded = true,
  })  : items = items,
        hintText = hintText,
        initialText = initialText,
        isExpanded = isExpanded,
        validator = validator,
        onSaved = onSaved;

  State<StatefulWidget> createState() => _State(initialText);
}

class _State extends State<MyDropdownFormField> {
  String value;

  _State(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: respWidthPercent(80),
      child: Padding(
        padding: EdgeInsets.only(top: respHeight(20)),
        child: Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: Theme.of(context).primaryColor),
          child: DropdownButtonFormField(
            onSaved: widget.onSaved,
            validator: widget.validator,
            decoration: formFieldInputDeco(hintText: widget.hintText),
            value: value,
            onChanged: (val) {
              setState(() {
                value = val;
              });
            },
            items: widget.items,
          ),
        ),
      ),
    );
  }
}

InputDecoration formFieldInputDeco(
    {IconButton suffixIcon,
    IconButton prefixIcon,
    String hintText,
    String errorTxt}) {
  return InputDecoration(
    alignLabelWithHint: true,
    errorStyle: TextStyle(
      color: Colors.white,
      backgroundColor: MyColours.red70a,
    ),
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    fillColor: MyColours.grey1,
    hintText: hintText,
    errorText: errorTxt,
    labelText: " $hintText ",
    labelStyle: TextStyle(
        backgroundColor: MyColours.grey1,
        color: MyColours.grey8,
        fontSize: respSP(18)),
    hintStyle: TextStyle(color: MyColours.grey8),
    filled: true,
    contentPadding: EdgeInsets.symmetric(
        horizontal: respWidth(20), vertical: respHeight(15)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.transparent)),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.transparent)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.transparent)),
  );
}

//InputDecoration formFieldInputDeco(
//    {IconButton suffixIcon,
//    IconButton prefixIcon,
//    String hintText,
//    String errorTxt}) {
//  return InputDecoration(
//    alignLabelWithHint: true,
//    errorStyle: TextStyle(
//      color: Colors.white,
//      backgroundColor: MyColours.red70a,
//    ),
//    suffixIcon: suffixIcon,
//    prefixIcon: prefixIcon,
//    fillColor: MyColours.grey1,
//    hintText: hintText,
//    errorText: errorTxt,
//    labelText: " $hintText ",
//    labelStyle:
//        TextStyle(backgroundColor: MyColours.grey1, color: MyColours.grey8),
//    hintStyle: TextStyle(color: MyColours.grey8),
//    filled: true,
//    contentPadding: EdgeInsets.symmetric(
//        horizontal: respWidth(20), vertical: respHeight(15)),
//    focusedBorder: OutlineInputBorder(
//        borderRadius: BorderRadius.circular(5.0),
//        borderSide: BorderSide(color: Colors.transparent)),
//    border: OutlineInputBorder(
//        borderRadius: BorderRadius.circular(5.0),
//        borderSide: BorderSide(color: Colors.transparent)),
//    enabledBorder: OutlineInputBorder(
//        borderRadius: BorderRadius.circular(5.0),
//        borderSide: BorderSide(color: Colors.transparent)),
//  );
//}
//
//Widget iconBtn(Icon icon, Function onPressed) {
//  return IconButton(
//    color: MyColours.grey9,
//    icon: icon,
//    onPressed: onPressed,
//  );
//}
