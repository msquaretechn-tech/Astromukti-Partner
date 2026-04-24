class UserModel {
  final String? uid;
  final String? id;
  final String? name;
  final String? lastName;
  final String? mobile;
  final String? gender;
  final String? dob;
  final bool? isNewUser;
  final String? dobTime;
  final String? birthPlace;
  final String? currentAddress;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? email;
  final String? fcmToken;
  final bool? isNotificationOn;
  final dynamic walletAmount;
  final dynamic latitude;
  final dynamic longitude;

  UserModel({
    this.uid,
    this.id,
    this.name,
    this.lastName,
    this.mobile,
    this.gender,
    this.dob,
    this.isNewUser,
    this.dobTime,
    this.birthPlace,
    this.currentAddress,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.email,
    this.fcmToken,
    this.isNotificationOn,
    this.walletAmount,
    this.latitude,
    this.longitude,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] as String?,
        id = json['_id'] as String?,
        name = json['name'] as String?,
        lastName = json['lastName'] as String?,
        mobile = json['mobile'] as String?,
        gender = json['gender'] as String?,
        dob = json['dob'] as String?,
        isNewUser = json['isNewUser'] as bool?,
        dobTime = json['dobTime'] as String?,
        birthPlace = json['birthPlace'] as String?,
        currentAddress = json['currentAddress'] as String?,
        avatar = json['avatar'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as int?,
        email = json['email'] as String?,
        fcmToken = json['fcmToken'] as String?,
        isNotificationOn = json['isNotificationOn'] as bool?,
        walletAmount = json['walletAmount'] as dynamic,
        latitude = json['latitude'] as dynamic?,
        longitude = json['longitude'] as dynamic?;

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    '_id' : id,
    'name' : name,
    'lastName' : lastName,
    'mobile' : mobile,
    'gender' : gender,
    'dob' : dob,
    'isNewUser' : isNewUser,
    'dobTime' : dobTime,
    'birthPlace' : birthPlace,
    'currentAddress' : currentAddress,
    'avatar' : avatar,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    '__v' : v,
    'email' : email,
    'fcmToken' : fcmToken,
    'isNotificationOn' : isNotificationOn,
    'walletAmount' : walletAmount,
    'latitude' : latitude,
    'longitude' : longitude,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}