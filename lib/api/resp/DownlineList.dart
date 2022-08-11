import 'package:charts_flutter/flutter.dart' as charts;

class DownlineList {
  final List<Downline> downlineList;

  DownlineList({
    this.downlineList,
  });

  factory DownlineList.fromJson(Map<String, dynamic> json) {
    // main list (tier-1)
    var mainList = json['downlineStats'] as List;

    return DownlineList(
      downlineList: mainList.map((i) => Downline.fromJson(i)).toList(),
    );
  }
}

class Downline {
  String userID;
  double totalPrice;
  charts.Color barColor;
  List<Downline> referralList;

  Downline({this.userID, this.totalPrice, this.referralList, this.barColor});

  factory Downline.fromJson(Map<String, dynamic> parsedJson) {
    // list of orders in a user
    var jsonOrderList = parsedJson["User"]["Orders"] as List;
    List<Order> orderList =
        jsonOrderList.map((i) => Order.fromJson(i)).toList();
    List<double> priceList =
        orderList.map((item) => item.orderItemTotalPrice).toList();

    // list of downlines in a user (tier-2)
    List<Downline> referralList;
    if (parsedJson["User"].containsKey("UserReferralTree")) {
      var jsonReferralList = parsedJson["User"]["UserReferralTree"] as List;
      referralList = jsonReferralList.map((i) => Downline.fromJson(i)).toList();
    }

    String memberCode = parsedJson["User"]["UserMembership"]["membership_code"];
    String memberID = parsedJson["User"]["UserMembership"]["membership_id"];

    return Downline(
        userID: "$memberCode$memberID",
        totalPrice: priceList.fold(0, (p, c) => p + c),
        referralList: referralList);
  }
}

class Order {
  String timeStamp;
  double orderItemTotalPrice;

  Order({this.timeStamp, this.orderItemTotalPrice});

  factory Order.fromJson(Map<String, dynamic> parsedJson) {
    var jsonOrderItemList = parsedJson["OrderItems"] as List;
    var deduction = parsedJson["deduction"];

    List<OrderItem> orderItemList =
    jsonOrderItemList.map((i) => OrderItem.fromJson(i)).toList();
    List<double> orderItemPriceList =
    orderItemList.map((item) => item.price).toList();

    // total price including deduction
    var totalPrice = orderItemPriceList.fold(0, (p, c) => p + c);
    totalPrice = totalPrice - deduction;

    return Order(
      timeStamp: parsedJson["created_at"],
      orderItemTotalPrice: totalPrice,
    );
  }
}

class OrderItem {
  double price;

  OrderItem({this.price});

  factory OrderItem.fromJson(Map<String, dynamic> parsedJson) {
    var totalPrice = parsedJson["total_price"];

    if (totalPrice is int) {
      totalPrice = totalPrice.toDouble();
    }

    return OrderItem(
      price: totalPrice,
    );
  }
}
