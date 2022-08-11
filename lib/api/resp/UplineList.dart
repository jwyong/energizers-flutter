class UplineList {
  final List<Upline> uplineList;

  UplineList({
    this.uplineList,
  });

  factory UplineList.fromJson(Map<String, dynamic> json) {
    var list = json['searchUser'] as List;
    List<Upline> uplineList = list.map((i) => Upline.fromJson(i)).toList();

    return UplineList(
      uplineList: uplineList,
    );
  }
}

class Upline {
  // displayable info
  String userID;
  String userName;

  // for registration
  String membershipCode, memberShipID;

  Upline({this.userID, this.userName, this.membershipCode, this.memberShipID});

  factory Upline.fromJson(Map<String, dynamic> parsedJson) {
    var memberShip = parsedJson['UserMembership'];
    String memberID = "", memberCode = "";

    if (memberShip != null) {
      memberCode = memberShip['membership_code'];
      memberID = memberShip['membership_id'];
    }

    return Upline(
      // displayable info
      userID: "$memberCode$memberID",
      userName: parsedJson["name"] as String,

      // for reg
      membershipCode: memberCode,
      memberShipID: memberID,
    );
  }
}
