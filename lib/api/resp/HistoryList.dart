class HistoryList {
  final List<History> historyList;

  HistoryList({
    this.historyList,
  });

  factory HistoryList.fromJson(Map<String, dynamic> json) {
    var list = json["User"]["UserTransactions"] as List;
    List<History> historyList = list.map((i) => History.fromJson(i)).toList();

    return HistoryList(
      historyList: historyList,
    );
  }
}

class History {
  String timeStamp, transID, cpEarnerd, vpEarned, qrCode, productFullName;

  History({this.timeStamp, this.transID, this.cpEarnerd, this.vpEarned, this.qrCode, this.productFullName});

  factory History.fromJson(Map<String, dynamic> parsedJson) {
    return History(
      timeStamp: parsedJson["created_at"],
      transID: parsedJson["transaction_id"],
      cpEarnerd: parsedJson["cp_point_earned"].toString(),
      vpEarned: parsedJson["vp_point_earned"].toString(),
      qrCode: parsedJson["ProductQr"]["product_qr_code"],
      productFullName: parsedJson["ProductQr"]["ProductBatch"]["product_full_name"],
    );
  }
}
