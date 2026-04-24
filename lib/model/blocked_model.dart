class BlockedModel {
  final String? id;
  final String? mobile;
  final String? avatar;
  final String? fcmToken;
  final String? lastName;
  final String? name;

  BlockedModel({
    this.id,
    this.mobile,
    this.avatar,
    this.fcmToken,
    this.lastName,
    this.name,
  });

  BlockedModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        mobile = json['mobile'] as String?,
        avatar = json['avatar'] as String?,
        fcmToken = json['fcmToken'] as String?,
        lastName = json['lastName'] as String?,
        name = json['name'] as String?;

  Map<String, dynamic> toJson() => {
    '_id' : id,
    'mobile' : mobile,
    'avatar' : avatar,
    'fcmToken' : fcmToken,
    'lastName' : lastName,
    'name' : name
  };
}