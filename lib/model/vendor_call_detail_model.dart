class VendorCallDetailModel {
  final String? id;
  final String? userId;
  final String? vendorId;
  final String? status;
  final String? type;
  final String? description;
  final dynamic duration;
  final dynamic amount;
  final bool? isRemedyAsigned;
  final String? disconnectedBy;
  final String? createdAt;
  final String? updatedAt;
  final dynamic v;
  final UserDetails? userDetails;
  final VendorDetails? vendorDetails;
  final List<ChatDetails>? chatDetails;
  final dynamic isBlocked;

  VendorCallDetailModel({
    this.id,
    this.userId,
    this.vendorId,
    this.status,
    this.type,
    this.description,
    this.duration,
    this.amount,
    this.isRemedyAsigned,
    this.disconnectedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userDetails,
    this.vendorDetails,
    this.chatDetails,
    this.isBlocked,
  });

  VendorCallDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        userId = json['userId'] as String?,
        vendorId = json['vendorId'] as String?,
        status = json['status'] as String?,
        type = json['type'] as String?,
        description = json['description'] as String?,
        duration = json['duration'] as dynamic,
        amount = json['amount'] as dynamic,
        isRemedyAsigned = json['isRemedyAsigned'] as bool?,
        disconnectedBy = json['disconnectedBy'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as dynamic,
        userDetails = (json['userDetails'] as Map<String, dynamic>?) != null
            ? UserDetails.fromJson(json['userDetails'] as Map<String, dynamic>)
            : null,
        vendorDetails = (json['vendorDetails'] as Map<String, dynamic>?) != null
            ? VendorDetails.fromJson(
                json['vendorDetails'] as Map<String, dynamic>)
            : null,
        chatDetails = (json['chatDetails'] as List?)
            ?.map(
                (dynamic e) => ChatDetails.fromJson(e as Map<String, dynamic>))
            .toList(),
        isBlocked = json['isBlocked'] as dynamic;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'vendorId': vendorId,
        'status': status,
        'type': type,
        'duration': duration,
        'amount': amount,
        'isRemedyAsigned': isRemedyAsigned,
        'disconnectedBy': disconnectedBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
        'userDetails': userDetails?.toJson(),
        'vendorDetails': vendorDetails?.toJson(),
        'chatDetails': chatDetails?.map((e) => e.toJson()).toList(),
        'isBlocked': isBlocked
      };
}

class UserDetails {
  final String? id;
  final String? uid;
  final String? name;
  final String? lastName;
  final dynamic mobile;
  final String? email;
  final String? dob;
  final String? dobTime;
  final String? birthPlace;
  final String? avatar;
  final String? createdAt;
  final String? fcmToken;
  final String? gender;

  UserDetails({
    this.id,
    this.uid,
    this.name,
    this.lastName,
    this.mobile,
    this.email,
    this.dob,
    this.dobTime,
    this.birthPlace,
    this.avatar,
    this.createdAt,
    this.fcmToken,
    this.gender,
  });

  UserDetails.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        uid = json['uid'] as String?,
        name = json['name'] as String?,
        lastName = json['lastName'] as String?,
        mobile = json['mobile'] as dynamic,
        email = json['email'] as String?,
        dob = json['dob'] as String?,
        dobTime = json['dobTime'] as String?,
        birthPlace = json['birthPlace'] as String?,
        avatar = json['avatar'] as String?,
        createdAt = json['createdAt'] as String?,
        fcmToken = json['fcmToken'] as String?,
        gender = json['gender'] as String?;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'uid': uid,
        'name': name,
        'lastName': lastName,
        'mobile': mobile,
        'email': email,
        'dob': dob,
        'dobTime': dobTime,
        'birthPlace': birthPlace,
        'avatar': avatar,
        'createdAt': createdAt,
        'fcmToken': fcmToken,
        'gender': gender
      };
}

class VendorDetails {
  final String? id;
  final String? uid;
  final String? name;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? avatar;
  final dynamic callRate;
  final dynamic videoCallRate;
  final dynamic chatRate;
  final dynamic emergencyCallRate;
  final dynamic privateCallRate;
  final dynamic anonymousCallRate;
  final List<dynamic>? blockedUsers;
  final String? createdAt;
  final String? fcmToken;

  VendorDetails({
    this.id,
    this.uid,
    this.name,
    this.lastName,
    this.email,
    this.mobile,
    this.avatar,
    this.callRate,
    this.videoCallRate,
    this.chatRate,
    this.emergencyCallRate,
    this.privateCallRate,
    this.anonymousCallRate,
    this.blockedUsers,
    this.createdAt,
    this.fcmToken,
  });

  VendorDetails.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        uid = json['uid'] as String?,
        name = json['name'] as String?,
        lastName = json['lastName'] as String?,
        email = json['email'] as String?,
        mobile = json['mobile'] as String?,
        avatar = json['avatar'] as String?,
        callRate = json['callRate'] as int?,
        videoCallRate = json['videoCallRate'] as dynamic,
        chatRate = json['chatRate'] as dynamic,
        emergencyCallRate = json['emergencyCallRate'] as dynamic,
        privateCallRate = json['privateCallRate'] as dynamic,
        anonymousCallRate = json['anonymousCallRate'] as dynamic,
        blockedUsers = json['blockedUsers'] as List?,
        createdAt = json['createdAt'] as String?,
        fcmToken = json['fcmToken'] as String?;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'uid': uid,
        'name': name,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'avatar': avatar,
        'callRate': callRate,
        'videoCallRate': videoCallRate,
        'chatRate': chatRate,
        'emergencyCallRate': emergencyCallRate,
        'privateCallRate': privateCallRate,
        'anonymousCallRate': anonymousCallRate,
        'blockedUsers': blockedUsers,
        'createdAt': createdAt,
        'fcmToken': fcmToken
      };
}

class ChatDetails {
  final String? id;

  ChatDetails({
    this.id,
  });

  ChatDetails.fromJson(Map<String, dynamic> json) : id = json['_id'] as String?;

  Map<String, dynamic> toJson() => {'_id': id};
}
