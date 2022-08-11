import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/HistoryList.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatefulWidget {
  @override
  HistoryTabState createState() => HistoryTabState();
}

class HistoryTabState extends State<HistoryTab>
    with AutomaticKeepAliveClientMixin<HistoryTab> {
  // basics
  SharedPreferences preferences;

  // for graphQL
  GraphQLClient graphQLClient;
  List<History> historyList = List<History>();

  // for swipe down to refresh
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      // init qr with auth token
      graphQLClient = initGraphQL(
          accessToken: prefs.getString(GlobalVars.PREF_ACCESS_TOKEN));
      getHistoryList();

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: getHistoryList,
      enablePullDown: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: respWidth(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: respHeight(20),
            ),
            // title
            homeTabsHeading(GlobalVars.getString(GlobalVars.HISTORY_TITLE)),
            SizedBox(
              height: respHeight(20),
            ),

            // instructions
            Text(
              GlobalVars.getString(GlobalVars.HISTORY_INST),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: respHeight(20),
            ),

            // box of history list
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: respWidth(15), vertical: respHeight(10)),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MyColours.white,
                  borderRadius: BorderRadius.circular(respWidth(10)),
                  border: Border.all(color: MyColours.grey4),
                ),
                child: historyListWidget(),
              ),
            ),
            SizedBox(
              height: respHeight(20),
            ),
          ],
        ),
      ),
    );
  }

  //===== widgets
  Widget historyListWidget() {
    return historyList.length == 0
        ?
        // show no history if none
        Center(
            child: Text(GlobalVars.getString(GlobalVars.HISTORY_NO_LIST)),
          )
        : ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];

              return historyListItem(history);
            });
  }

  Widget historyListItem(History item) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            // date col
            historyDateCol(item.timeStamp),

            SizedBox(
              width: respWidth(5),
            ),

            // details col
            Expanded(
              child: historyDetsCol(item),
            ),
          ],
        ),
        Divider(
          color: MyColours.grey4,
        )
      ],
    );
  }

  Widget historyDateCol(String timeStamp) {
    return Column(
      children: <Widget>[
        // date
        Text(DateFormat('dd MMM yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp)))),

        // time
        Text(DateFormat('KK:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))))
      ],
    );
  }

  Widget historyDetsCol(History item) {
    return Column(
      children: <Widget>[
        // prod name
        Text(
          item.productFullName,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),

        // qrCode
        Text(
          item.qrCode,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            cpVpItem("CP: ${item.cpEarnerd}"),
            SizedBox(
              width: respWidth(5),
            ),
            cpVpItem("VP: ${item.vpEarned}"),
          ],
        )
      ],
    );
  }

  Widget cpVpItem(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  //===== http funcs
  void getHistoryList() async {
    if (preferences != null) {
      graphQLClient = null;
      graphQLClient = initGraphQL(
          accessToken: preferences.getString(GlobalVars.PREF_ACCESS_TOKEN));
    }

    QueryOptions options = QueryOptions(
      document: queryQrHistory,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (result.hasErrors) {
      // update refreshUI
      _refreshController.refreshFailed();

      respError(context, result);
    } else {
      respSuccess(result.data);
    }
  }

  void respSuccess(data) {
    // update UI
    _refreshController.refreshCompleted();

    setState(() {
      historyList = HistoryList.fromJson(data).historyList;
    });
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
