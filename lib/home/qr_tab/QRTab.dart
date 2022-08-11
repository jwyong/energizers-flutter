import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/home/qr_tab/QRForm.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRTab extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<QRTab> with AutomaticKeepAliveClientMixin<QRTab> {
  // basics
  SharedPreferences preferences;

  // for graphQL
  GraphQLClient graphQLClient;

  // qr results text
  String qrResText = GlobalVars.getString(GlobalVars.QR_DESC_INITIAL);

  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: respHeight(20), horizontal: respWidth(30)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // title
          homeTabsHeading(GlobalVars.getString("qr_title")),
          SizedBox(
            height: respHeight(20),
          ),

          // instructions
          Text(
            GlobalVars.getString("qr_instructions"),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: respHeight(20),
          ),

          // card with qr code img
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MyColours.white,
                borderRadius: BorderRadius.circular(respWidth(10)),
                border: Border.all(color: MyColours.grey4),
              ),
              child: cardContents(),
            ),
          ),
          SizedBox(
            height: respHeight(20),
          ),

          // start scanning qr btn
          MyRaisedBtn(
            GlobalVars.getString("qr_start"),
            barcodeScanning,
          ),
        ],
      ),
    );
  }

  //===== widgets
  Widget cardContents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: respHeight(20),
        ),

        // camera icon
        InkWell(
          onTap: barcodeScanning,
//          onTap: () {
//            Navigator.push(
//              context,
//              CupertinoPageRoute(
//                  builder: (context) => QRForm(updateResultsText)),
//            );
//          },
          child: Icon(
            Icons.camera_alt,
            size: respWidthPercent(20),
          ),
        ),

        SizedBox(
          height: respHeight(15),
        ),

        // text description - show results text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: respWidth(20)),
          child: Text(
            qrResText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: respSP(18), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  //===== funcs
  Future barcodeScanning() async {
    try {
      String scannedCode = await BarcodeScanner.scan();

      // post scanned qr to check if already claimed
      postCheckQR(scannedCode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        toastMsg(context, GlobalVars.getString("perm_camera_no"));
      } else {
        toastMsg(context, GlobalVars.getString("generic_error"));
      }
    } on FormatException {
      // exit without scanning
    }
  }

  void updateResultsText(String resultsText) {
    setState(() {
      this.qrResText = resultsText;
    });
  }

  //===== http funcs
  void postCheckQR(String qrCode) async {
    if (preferences != null) {
      graphQLClient = null;
      graphQLClient = initGraphQL(
          accessToken: preferences.getString(GlobalVars.PREF_ACCESS_TOKEN));
    }

    // update UI
    updateResultsText(GlobalVars.getString(GlobalVars.LOADING));

    QueryOptions options = QueryOptions(
      document: queryCheckQR,
      variables: <String, dynamic>{
        'qrCode': qrCode,
      },
    );

    final QueryResult result = await graphQLClient.query(options);

    print("${GlobalVars.TAG}, QRTab, _State.postCheckQR: res = $result");

    if (result.hasErrors) {
      // update UI - claimed
      updateResultsText(GlobalVars.getString(GlobalVars.QR_UNSUC));

      respError(context, result);
    } else {
      respSuccess(result.data, qrCode);
    }
  }

  void respSuccess(data, String qrCode) {
    // update UI
    updateResultsText(GlobalVars.getString(GlobalVars.QR_CHECK_SUCCESS));

    // go to form
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => QRForm(updateResultsText, qrCode)),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
