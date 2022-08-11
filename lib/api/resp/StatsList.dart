import 'DownlineList.dart';

class StatsList {
  final List<Order> orderList;
  int quarterTarget, yearTarget;

  StatsList({
    this.orderList,
    this.quarterTarget,
    this.yearTarget
  });

  factory StatsList.fromJson(Map<String, dynamic> json) {
    var orderList = json['User']["Orders"] as List;

    return StatsList(
      quarterTarget: json["User"]["UserMembership"]["UserMembershipCode"]["sales_target_quarterly"],
      yearTarget: json["User"]["UserMembership"]["UserMembershipCode"]["sales_target_yearly"],
      orderList: orderList.map((i) => Order.fromJson(i)).toList(),
    );
  }
}