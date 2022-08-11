class CPVPList {
  final String memberCode, memberID;
  final List<CPVP> cpVpList;

  CPVPList({
    this.memberCode,
    this.memberID,
    this.cpVpList,
  });

  factory CPVPList.fromJson(Map<String, dynamic> json) {
    var memberCode = json['User']['UserMembership']['membership_code'];
    var memberID = json['User']['UserMembership']['membership_id'];
    var list = json["User"]["UserTransactions"] as List;

    List<CPVP> cpVpList = list.map((i) => CPVP.fromJson(i)).toList();

    return CPVPList(
      memberCode: memberCode,
      memberID: memberID,
      cpVpList: cpVpList,
    );
  }
}

class CPVP {
  String cpEarnerd, vpEarned;

  CPVP({this.cpEarnerd, this.vpEarned});

  factory CPVP.fromJson(Map<String, dynamic> parsedJson) {
    return CPVP(
      cpEarnerd: parsedJson["cp_point_earned"].toString(),
      vpEarned: parsedJson["vp_point_earned"].toString(),
    );
  }
}
