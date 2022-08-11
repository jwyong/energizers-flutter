import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/global/ValidationHelper.dart';
import 'package:energizers/widgets/MyDropdownFormField.dart';
import 'package:energizers/widgets/MyFormField.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/MyToolbar.dart';
import 'package:energizers/widgets/ScrollableActiView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRForm extends StatefulWidget {
  Function updateResultsText;
  String qrCode;

  QRForm(this.updateResultsText, this.qrCode);

  // for finish
  bool canPop = false;

  @override
  _State createState() => _State();
}

class _State extends State<QRForm> {
  // basics
  SharedPreferences preferences;

  // for graphQL
  GraphQLClient graphQLClient;

  // form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<int> carTypeList = List<int>();
  bool isBtnEnabled = true;

  @override
  void initState() {
    super.initState();

    formData.clear();

    SharedPreferences.getInstance().then((prefs) {
      // init qr with auth token
      graphQLClient = initGraphQL(
          accessToken: prefs.getString(GlobalVars.PREF_ACCESS_TOKEN));

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext ctx) {
    // set status bar text colour
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: MyColours.black,
    ));

    return Scaffold(
      appBar: MyToolbar(
        context: ctx,
        title: GlobalVars.getString(GlobalVars.QR_FORM_TITLE),
      ),
      backgroundColor: MyColours.white,
      body: ScrollableActiView(
        padding: EdgeInsets.symmetric(horizontal: respWidth(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // title (qr code)
            homeTabsHeading(widget.qrCode),
            SizedBox(
              height: respHeight(20),
            ),

            // instructions
            Text(GlobalVars.getString(GlobalVars.QR_FORM_DESC)),
            SizedBox(
              height: respHeight(20),
            ),

            // form
            form(),
            SizedBox(
              height: respHeight(15),
            ),

            // grped btns
            grpedBtns(),

            SizedBox(
              height: respHeight(20),
            ),

            // submit btn
            MyRaisedBtn(
                GlobalVars.getString(GlobalVars.SUBMIT),
                isBtnEnabled
                    ? () {
                        submitBtnOnClick(ctx);
                      }
                    : null),
          ],
        ),
      ),
//      ),
    );
  }

  //===== widgets
  Widget form() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          // 1 - car plate no
          MyFormField(
            hintText: GlobalVars.getString(GlobalVars.QR_FORM_CAR_PLATE_NO),
            validator: validateEmpty,
            onSaved: setFormData1,
          ),

          // 2 - car manu year
          MyDropdownFormField(
            hintText: GlobalVars.getString(GlobalVars.QR_FORM_CAR_MANU_YEAR),
            validator: validateEmpty,
            onSaved: setFormData2,
            items: <String>[
              '1-3 ${GlobalVars.getString(GlobalVars.YEARS)}',
              '4-6 ${GlobalVars.getString(GlobalVars.YEARS)}',
              '7-9 ${GlobalVars.getString(GlobalVars.YEARS)}',
              '>9 ${GlobalVars.getString(GlobalVars.YEARS)}'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget grpedBtns() {
    return Row(
      children: <Widget>[
        // recon
        grpedBtnsItem(GlobalVars.getString(GlobalVars.QR_FORM_CAR_TYPE_RECON),
            () {
          addRemoveCarType(0);
        }, 0),

        SizedBox(
          width: respWidth(5),
        ),

        // overhaul
        grpedBtnsItem(
            GlobalVars.getString(GlobalVars.QR_FORM_CAR_TYPE_OVERHAUL), () {
          addRemoveCarType(1);
        }, 1)
      ],
    );
  }

  Widget grpedBtnsItem(String text, Function onTap, int index) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: carTypeList.contains(index)
                  ? MyColours.purple1
                  : MyColours.white,
              border: Border.all(color: MyColours.grey4),
              borderRadius: index == 0
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20))
                  : BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: respHeight(10)),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: carTypeList.contains(index)
                      ? MyColours.white
                      : MyColours.black),
            ),
          ),
        ),
      ),
    );
  }

  //===== funcs
  void submitBtnOnClick(BuildContext ctx) {
    // validate
    if (formKey.currentState.validate()) {
      // disable btn
      setState(() {
        isBtnEnabled = false;
      });
      formKey.currentState.save();

      // show confirmation popup
      showAlert2Btns(ctx,
          desc: GlobalVars.getString(GlobalVars.QR_FORM_SUBMIT_CONFIRM),
          positiveFunc: () {
        postQRForm(ctx);
      });
    }
  }

  // add/remove index for carType multi-select btn grps
  void addRemoveCarType(int index) {
    setState(() {
      if (carTypeList.contains(index)) {
        carTypeList.remove(index);
      } else {
        carTypeList.add(index);
      }
    });
  }

  //===== http funcs
  // post qr form on qr claim success
  void postQRForm(BuildContext ctx) async {
    MutationOptions options = MutationOptions(
      document: mutateClaimQR,
      variables: <String, dynamic>{
        'qrCode': widget.qrCode,
        'carNo': formData[1],
        'carYear': formData[2],
        'recon': carTypeList.contains(0) ? 1 : 0,
        'overhaul': carTypeList.contains(1) ? 1 : 0,
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);

    // update UI
    setState(() {
      isBtnEnabled = true;
    });

    if (result.hasErrors) {
      // update UI
//      widget.updateResultsText(GlobalVars.getString(GlobalVars.QR_UNSUC));

      respError(context, result);
    } else {
      respQRFormSuccess(ctx, result.data);
    }
  }

  void respQRFormSuccess(BuildContext ctx, data) {
    // toast + updateUI success
    widget.updateResultsText(GlobalVars.getString(GlobalVars.QR_FORM_SUCCESS));

    // finish
//    Navigator.pop(ctx);
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
