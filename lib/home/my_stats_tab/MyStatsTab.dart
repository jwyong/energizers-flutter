import 'dart:developer';

import 'package:charts_flutter/flutter.dart';
import 'package:energizers/api/GraphQLClient.dart';
import 'package:energizers/api/GraphQLQueries.dart';
import 'package:energizers/api/resp/StatsList.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/widgets/MyRaisedBtn.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:graphql/client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MyStatsTab extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyStatsTab>
    with AutomaticKeepAliveClientMixin<MyStatsTab> {
  // basics
  SharedPreferences preferences;

  // for graphQL
  GraphQLClient graphQLClient;
  StatsList statsList = StatsList(quarterTarget: 0, yearTarget: 0);
  String desc = GlobalVars.getString(GlobalVars.LOADING);

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
      getStatsList();

      setState(() {
        preferences = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: getStatsList,
      enablePullDown: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: respWidth(30)),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: respHeight(20),
            ),
            // title
            homeTabsHeading(GlobalVars.getString("my_stats")),
            // show downline click instructions if got
            if (statsList.orderList != null)
              Text(
                GlobalVars.getString(GlobalVars.MY_STATS_CLICK_INST),
                textAlign: TextAlign.center,
              ),
            SizedBox(
              height: respHeight(20),
            ),

            // show downline charts if got
            if (statsList.orderList != null)
              // quarterly sales chart
              qsChart(0)
            else
              Text(desc),

            SizedBox(
              height: respHeight(20),
            ),

            if (statsList.orderList != null)
              // yearly sales chart
              qsChart(1),

            SizedBox(
              height: respHeight(20),
            ),
          ],
        ),
      ),
    );
  }

  //===== widgets
  Widget qsChart(int type) {
    return Expanded(
        child: Container(
      decoration:
          BoxDecoration(border: Border.all(color: MyColours.lightBlue1)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: respWidth(20), vertical: respHeight(20)),
        child: charts.BarChart(
          type == 0 ? getQSList() : getYSList(),
          animate: false,
          primaryMeasureAxis: charts.AxisSpec(
              tickProviderSpec:
                  charts.BasicNumericTickProviderSpec(desiredTickCount: 5)),

          // show label in bar
          barRendererDecorator: charts.BarLabelDecorator<String>(),

          barGroupingType: charts.BarGroupingType.grouped,
          // Add the series legend behavior to the chart to turn on series legends.
          // By default the legend will display above the chart.
          behaviors: [
            charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
            charts.ChartTitle(
              type == 0
                  ? GlobalVars.getString("quarter_sales")
                  : GlobalVars.getString("year_sales"),
              innerPadding: respHeight(20).toInt(),
            ),
          ],

          selectionModels: [
            charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: graphOnChange,
            )
          ],
        ),
      ),
    ));
  }

//===== funcs
  void graphOnChange(SelectionModel<String> selectionModel) {
    // get sales or target
    String id = selectionModel.selectedSeries.first.id;

    // get x and y vals
    String quarter = selectionModel.selectedDatum.first.datum.xAxisLabel;
    double yVal = selectionModel.selectedDatum.first.datum.yAxisVal;
    String salesStr = formatDecimal(yVal);

    // toast user on selected value
    toastMsg(context, "$quarter $id: $salesStr",
        position: FlushbarPosition.TOP, duration: 4);
  }

  // list for quarterly sales
  List<charts.Series<GraphData, String>> getQSList() {
    // map stats list to 4 quarters first
    List<double> q1SalesList = statsList.orderList
        .map((item) => getMonth(int.parse(item.timeStamp)) <= 3
            ? item.orderItemTotalPrice
            : 0.0)
        .toList();
    double q1TotalSales = q1SalesList.fold(0, (p, c) => p + c);

    List<double> q2SalesList = statsList.orderList
        .map((item) => (getMonth(int.parse(item.timeStamp)) > 3 &&
                getMonth(int.parse(item.timeStamp)) <= 6)
            ? item.orderItemTotalPrice
            : 0.0)
        .toList();
    double q2TotalSales = q2SalesList.fold(0, (p, c) => p + c);

    List<double> q3SalesList = statsList.orderList
        .map((item) => (getMonth(int.parse(item.timeStamp)) > 6 &&
                getMonth(int.parse(item.timeStamp)) <= 9)
            ? item.orderItemTotalPrice
            : 0.0)
        .toList();
    double q3TotalSales = q3SalesList.fold(0, (p, c) => p + c);

    List<double> q4SalesList = statsList.orderList
        .map((item) => getMonth(int.parse(item.timeStamp)) > 9
            ? item.orderItemTotalPrice
            : 0.0)
        .toList();
    double q4TotalSales = q4SalesList.fold(0, (p, c) => p + c);

    final salesGraphData = [
      GraphData(GlobalVars.getString("q1"), q1TotalSales),
      GraphData(GlobalVars.getString("q2"), q2TotalSales),
      GraphData(GlobalVars.getString("q3"), q3TotalSales),
      GraphData(GlobalVars.getString("q4"), q4TotalSales),
    ];

    int quarterTarget = statsList.quarterTarget;
    final targetGraphData = [
      GraphData(GlobalVars.getString("q1"), quarterTarget.toDouble()),
      GraphData(GlobalVars.getString("q2"), quarterTarget.toDouble()),
      GraphData(GlobalVars.getString("q3"), quarterTarget.toDouble()),
      GraphData(GlobalVars.getString("q4"), quarterTarget.toDouble()),
    ];

    return [
      charts.Series<GraphData, String>(
        id: GlobalVars.getString("sales"),
        domainFn: (GraphData sales, _) => sales.xAxisLabel,
        measureFn: (GraphData sales, _) => sales.yAxisVal,
        data: salesGraphData,
        labelAccessorFn: (GraphData item, _) => "",
      ),
      charts.Series<GraphData, String>(
        id: GlobalVars.getString("target"),
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (GraphData sales, _) => sales.xAxisLabel,
        measureFn: (GraphData sales, _) => sales.yAxisVal,
        data: targetGraphData,
        labelAccessorFn: (GraphData item, _) => "",
      ),
    ];
  }

  // list for yearly sales
  List<charts.Series<GraphData, String>> getYSList() {
    List<double> yearSalesList =
        statsList.orderList.map((item) => item.orderItemTotalPrice).toList();
    double yearTotalSales = yearSalesList.fold(0, (p, c) => p + c);

    final salesGraphData = [
      GraphData(GlobalVars.getString("yearly"), yearTotalSales),
    ];

    final targetGraphData = [
      GraphData(GlobalVars.getString("yearly"), statsList.yearTarget.toDouble()),
    ];

    return [
      charts.Series<GraphData, String>(
        id: GlobalVars.getString("sales"),
        domainFn: (GraphData sales, _) => sales.xAxisLabel,
        measureFn: (GraphData sales, _) => sales.yAxisVal,
        data: salesGraphData,
        labelAccessorFn: (GraphData item, _) =>
            formatDecimal(item.yAxisVal),
      ),
      charts.Series<GraphData, String>(
        id: GlobalVars.getString("target"),
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (GraphData sales, _) => sales.xAxisLabel,
        measureFn: (GraphData sales, _) => sales.yAxisVal,
        data: targetGraphData,
        labelAccessorFn: (GraphData item, _) =>
            formatDecimal(item.yAxisVal),
      ),
    ];
  }

  // format decimals to whole number or 2 digits (1500 or 1500.30)
  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  // get month from a timestamp
  var monthFormat = DateFormat("M");

  int getMonth(int timeStamp) {
    return int.parse(
        monthFormat.format(DateTime.fromMillisecondsSinceEpoch(timeStamp)));
  }

  //===== http funcs
  void getStatsList() async {
    if (preferences != null) {
      graphQLClient = null;
      graphQLClient = initGraphQL(
          accessToken: preferences.getString(GlobalVars.PREF_ACCESS_TOKEN));
    }

    QueryOptions options = QueryOptions(
      document: queryMyStats,
      variables: <String, dynamic>{},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (result.hasErrors) {
      // update refreshUI
      _refreshController.refreshFailed();

      // show refresh instructions
      setState(() {
        desc = GlobalVars.getString(GlobalVars.MY_STATS_INST);
      });

      respError(context, result);
    } else {
      respSuccess(result.data);
    }
  }

  void respSuccess(data) {
    // update UI
    _refreshController.refreshCompleted();

    setState(() {
      statsList = StatsList.fromJson(data);
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

//===== vm classes
class GraphData {
  final String xAxisLabel;
  final double yAxisVal;

  GraphData(this.xAxisLabel, this.yAxisVal);
}
