class FollowModel {
  final String? id;
  final FollowerDetails? followerDetails;

  FollowModel({
    this.id,
    this.followerDetails,
  });

  FollowModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        followerDetails =
            (json['followerDetails'] as Map<String, dynamic>?) != null
                ? FollowerDetails.fromJson(
                    json['followerDetails'] as Map<String, dynamic>)
                : null;

  Map<String, dynamic> toJson() =>
      {'_id': id, 'followerDetails': followerDetails?.toJson()};
}

class FollowerDetails {
  final String? id;
  final String? name;
  final String? lastName;
  final dynamic mobile;
  final String? email;
  final String? avatar;
  final String? fcmToken;
  final bool? isNotificationOn;

  FollowerDetails({
    this.id,
    this.name,
    this.lastName,
    this.mobile,
    this.email,
    this.avatar,
    this.fcmToken,
    this.isNotificationOn,
  });

  FollowerDetails.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        name = json['name'] as String?,
        lastName = json['lastName'] as String?,
        mobile = json['mobile'] as dynamic,
        email = json['email'] as String?,
        avatar = json['avatar'] as String?,
        fcmToken = json['fcmToken'] as String?,
        isNotificationOn = json['isNotificationOn'] as bool?;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'lastName': lastName,
        'mobile': mobile,
        'email': email,
        'avatar': avatar,
        'fcmToken': fcmToken,
        'isNotificationOn': isNotificationOn
      };
}
