import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:flutter/material.dart';
import 'package:energizers/global/MyColours.dart';

class MyFormField extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  final bool autoFocus;
  final int maxLines;
  final int maxLength;
  final String hintText;
  final String initialText;
  final bool enabled;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final FormFieldSetter<String> onSaved;
  final TextInputType textInputType;
  final bool obscureText;
  final IconButton prefixIcon;
  final IconButton suffixIcon;

  MyFormField({
    TextEditingController controller,
    int maxLines = 1,
    int maxLength,
    bool enabled = true,
    bool autoFocus = false,
    String hintText,
    String initialText,
    FocusNode focusNode,
    TextInputAction textInputAction = TextInputAction.next,
    FormFieldValidator<String> validator,
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    TextInputType textInputType = TextInputType.text,
    bool obscureText = false,
    IconButton prefixIcon,
    IconButton suffixIcon,
  })  : hintText = hintText,
        enabled = enabled,
        maxLength = maxLength,
        maxLines = maxLines,
        controller = controller,
        autoFocus = autoFocus,
        initialText = initialText,
        focusNode = focusNode,
        textInputAction = textInputAction,
        validator = validator,
        onFieldSubmitted = onFieldSubmitted,
        onSaved = onSaved,
        textInputType = textInputType,
        obscureText = obscureText,
        prefixIcon = prefixIcon,
        suffixIcon = suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: respWidthPercent(80),
      child: Padding(
        padding: EdgeInsets.only(top: respHeight(20)),
        child: TextFormField(
          enabled: enabled,
          controller: controller,
          onSaved: onSaved,
          maxLength: maxLength,
          maxLines: maxLines,
          autofocus: autoFocus,
          obscureText: this.obscureText,
          focusNode: focusNode,
          textAlign: TextAlign.start,
          keyboardType: this.textInputType,
          validator: validator,
          onFieldSubmitted: this.onFieldSubmitted,
          textInputAction: this.textInputAction,
          style: TextStyle(fontSize: respSP(18)),
          initialValue: initialText,
          decoration: formFieldInputDeco(
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              hintText: hintText),
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
    labelStyle:
        TextStyle(backgroundColor: MyColours.grey1, color: MyColours.grey8),
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

Widget iconBtn(Icon icon, Function onPressed) {
  return IconButton(
    color: MyColours.grey9,
    icon: icon,
    onPressed: onPressed,
  );
}
