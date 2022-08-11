import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/DownlineList.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:graphql/client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DownlineTab extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<DownlineTab>
    with AutomaticKeepAliveClientMixin<DownlineTab> {
  // basics
  SharedPreferences preferences;

  // for graphQL
  GraphQLClient graphQLClient;
  List<Downline> downlineList = List<Downline>();
  String downlineDesc = GlobalVars.getString(GlobalVars.DOWNLINE_INST);

  // for swipe down to refresh
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      graphQLClient = initGraphQL(
          accessToken: prefs.getString(GlobalVars.PREF_ACCESS_TOKEN));
      getDownlineSales();

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        controller: _refreshController,
        onRefresh: getDownlineSales,
        enablePullDown: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: respWidth(30)),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: respHeight(20),
              ),
              // title
              homeTabsHeading(GlobalVars.getString(GlobalVars.DOWNLINE_TITLE)),

              // hori chart
              SizedBox(
                height: respHeight(20),
              ),

              // show downline chart if got
              if (downlineList.length > 0)
                downlineChart()
              else
                Text(downlineDesc),

              SizedBox(
                height: respHeight(20),
//            ),
//          ],
//        ),
              ),
            ],
          ),
        ));
  }

  //===== widgets
  Widget downlineChart() {
    return Expanded(
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: MyColours.lightBlue1)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: respWidth(20), vertical: respHeight(20)),
          child: charts.BarChart(
            getHoriList(),
            vertical: false,
            animate: false,

            // for scrolling/panning
//            flipVerticalAxis: true,
//            domainAxis: charts.OrdinalAxisSpec(
//              viewport: charts.OrdinalViewport('AePS', 10),
//            ),
            primaryMeasureAxis: charts.AxisSpec(
                tickProviderSpec:
                    charts.BasicNumericTickProviderSpec(desiredTickCount: 5)),

            // show label in bar
            barRendererDecorator: charts.BarLabelDecorator<String>(),

            barGroupingType: charts.BarGroupingType.grouped,
            // Add the series legend behavior to the chart to turn on series legends.
            // By default the legend will display above the chart.
            behaviors: [
              charts.SlidingViewport(),
              charts.PanBehavior(),
//              charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
              charts.ChartTitle(
                GlobalVars.getString("sales"),
                innerPadding: respHeight(20).toInt(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //===== funcs
  // list for downline sales
  List<charts.Series<GraphData, String>> getHoriList() {
    // loop through each referral to get downline (tier 1)
    List<GraphData> graphList = downlineList
        .map((item) => GraphData(item.userID, item.totalPrice,
            charts.Color.fromHex(code: "#42A5F5")))
        .toList();

    // dummy data
//    graphList.add(GraphData("TEST1", 12345, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST2", 11112, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST3", 4213, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST4", 231, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST5", 4354, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST6", 6345, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST7", 4356, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST8", 434, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST9", 3454, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST0", 3453, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST-", 345, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST=", 6645, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST12", 3534, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST23", 9778, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST24", 2534, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST25", 6756, charts.Color.fromHex(code: "#42A5F5")));
//    graphList.add(GraphData("TEST15", 8865, charts.Color.fromHex(code: "#42A5F5")));

    // loop through referral list (tier-2)
    for (var i = 0; i < downlineList.length; i++) {
      for (var j = 0; j < downlineList[i].referralList.length; j++) {
        graphList.add(GraphData(
            downlineList[i].referralList[j].userID,
            downlineList[i].referralList[j].totalPrice,
            charts.Color.fromHex(code: "#81C784")));
      }
    }

    return [
      charts.Series<GraphData, String>(
        id: GlobalVars.getString("sales"),
        domainFn: (GraphData item, _) => item.xAxisLabel,
        measureFn: (GraphData item, _) => item.yAxisVal,
        colorFn: (GraphData item, _) => item.barColor,
        data: graphList,
        labelAccessorFn: (GraphData item, _) =>
            formatDecimal(item.yAxisVal),
      ),
    ];
  }

  // format decimals to whole number or 2 digits (1500 or 1500.30)
  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  //===== http funcs
  Future<void> _refresh() {
    getDownlineSales();
  }

  void getDownlineSales() async {
    if (preferences != null) {
      graphQLClient = null;
      graphQLClient = initGraphQL(
          accessToken: preferences.getString(GlobalVars.PREF_ACCESS_TOKEN));
    }

    QueryOptions options = QueryOptions(
      document: queryDownlineSales,
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
      downlineList = DownlineList.fromJson(data).downlineList;
      if (downlineList.isEmpty) {
        downlineDesc = GlobalVars.getString(GlobalVars.DOWNLINE_NO);
      }
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

class GraphData {
  final String xAxisLabel;
  final double yAxisVal;
  final charts.Color barColor;

  GraphData(this.xAxisLabel, this.yAxisVal, this.barColor);
}
