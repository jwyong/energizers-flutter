import 'package:energizers/global/ScreenUtilHelper.dart';
import 'package:energizers/global/UIHelper.dart';
import 'package:energizers/home/qr_tab/QRTab.dart';
import 'package:energizers/home/settings_tab/SettingsTab.dart';
import 'package:energizers/registration/Login.dart';
import 'package:energizers/home/HomeTabsDrawer.dart';
import 'package:energizers/widgets/MyText.dart';
import 'package:energizers/widgets/MyToolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:energizers/global/MyColours.dart';
import 'package:energizers/global/GlobalVars.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'downline_tab/DownlineTab.dart';
import 'history_tab/HistoryTab.dart';
import 'my_stats_tab/MyStatsTab.dart';

class HomeTabs extends StatefulWidget {
  int initialTab;

  HomeTabs({this.initialTab});

  static const String routeName = "/hometabs";

  @override
  HomeTabsState createState() => HomeTabsState();
}

// SingleTickerProviderStateMixin is used for animation
class HomeTabsState extends State<HomeTabs> with TickerProviderStateMixin {
  // basics
  SharedPreferences preferences;
  String userName = "";
  int userTypeInt = 1;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Create a tab controller
  TabController controller;

  @override
  void initState() {
    super.initState();

    // get data from pref
    SharedPreferences.getInstance().then((prefs) {
      // set stage int to 1
      prefs.setInt(GlobalVars.PREF_STAGE_INT, 1);

      // set user info
      userTypeInt = prefs.getInt(GlobalVars.PREF_USER_TYPE) ?? 1;
      userName = prefs.getString(GlobalVars.PREF_USERNAME);

      setState(() {
        preferences = prefs;
      });
    });

    // Initialize the Tab Controller
    controller = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTab ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtil(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: MyToolbar(
          scaffoldKey: scaffoldKey,
          context: context,
          title: GlobalVars.app_name,
          isDrawerBtn: true),

      // drawer for profile img, logout, etc
      drawer: SafeArea(child: HomeTabsDrawer()),

      // main content body
      body: TabBarView(
//        physics: NeverScrollableScrollPhysics(),
        // Add tabs as widgets
        children: <Widget>[
          // member
          if (userTypeInt == 2)
            MyStatsTab(),
          if (userTypeInt == 2)
            DownlineTab(),

          // ambassador
          if (userTypeInt == 1)
            QRTab(),
          if (userTypeInt == 1)
            HistoryTab(),

          // universal
          SettingsTab()
        ],
        // set the controller
        controller: controller,
      ),

      // bottom tab bars
      bottomNavigationBar: Material(
        // background colour
        color: MyColours.purple1,
        // set the tab bar as the child of bottom navigation bar
        child: SafeArea(
          child: TabBar(
            // selected colour
            indicator: BoxDecoration(color: MyColours.black70a),

            // hide underline indicator
//          indicator: UnderlineTabIndicator(
//              borderSide: BorderSide(color: MyColours.darkBlue2)),
            tabs: <Tab>[
              // member
              if (userTypeInt == 2)
                tabItem(Icons.dashboard, GlobalVars.getString("my_stats")),
              if (userTypeInt == 2)
                tabItem(Icons.supervised_user_circle,
                    GlobalVars.getString("downline")),

              // foreman
              if (userTypeInt == 1)
                tabItem(Icons.camera_alt, GlobalVars.getString("qr")),
              if (userTypeInt == 1)
                tabItem(Icons.history, GlobalVars.getString("history")),

              // universal
              tabItem(Icons.settings, GlobalVars.getString("settings")),
            ],
            // setup the controller
            controller: controller,
          ),
        ),
      ),
    );
  }

  //===== widget
  // top drawer

  Widget tabItem(IconData icon, String label) {
    return Tab(
      // set icon to the tab
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: MyColours.white,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: MyColours.white),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
