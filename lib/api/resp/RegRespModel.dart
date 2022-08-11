class RegRespModel {
  String accessToken;

  RegRespModel({this.accessToken});

  factory RegRespModel.fromJson(Map<String, dynamic> parsedJson) {
    return RegRespModel(
      // displayable info
      accessToken: parsedJson["registerUser"] as String,
    );
  }
}