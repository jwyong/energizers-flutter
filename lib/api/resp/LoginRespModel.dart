class LoginRespModel {
  String userName, accessToken;
  int userTypeInt;

  LoginRespModel({this.userName, this.accessToken, this.userTypeInt});

  factory LoginRespModel.fromJson(Map<String, dynamic> parsedJson) {
    var loginUser = parsedJson['loginUser'];

    return LoginRespModel(
      // displayable info
      userName: loginUser["name"] as String,
      accessToken: loginUser["OauthAccessToken"]["access_token_id"] as String,
      userTypeInt: loginUser["UserMembership"]["user_type_id"] as int,
    );
  }
}
