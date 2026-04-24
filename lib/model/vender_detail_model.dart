class VendorDetailsModel {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? avatar;
  final String? dob;
  final String? gender;
  final List<String>? skills;
  final int? experienceYear;
  final List<String>? languages;
  final String? maritalStatus;
  final int? workingHours;
  final bool? exclusiveStatus;
  final String? address;
  final int? pincode;
  final String? bio;
  final bool? isFulltimeJob;
  final String? currentDevice;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final int? callRate;
  final int? chatRate;
  final int? videoCallRate;
  final int? privateCallRate;
  final int? anonymousCallRate;
  final bool? isLive;
  final bool? isOnline;
  final bool? isAudioCallAvailable;
  final bool? isAnonymousCallAvailable;
  final bool? isPrivateCallAvailable;
  final bool? isVideoCallAvailable;
  final bool? isChatAvailable;
  final dynamic nextUpComingTime;
  final dynamic averageRating;
  final dynamic walletAmount;
  final int? totalRatingCount;
  final String? fcmToken;
  final String? chatGroupId;
  final String? callChannelName;
  final bool? isFollowing;

  VendorDetailsModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.avatar,
    this.dob,
    this.gender,
    this.skills,
    this.experienceYear,
    this.languages,
    this.maritalStatus,
    this.workingHours,
    this.exclusiveStatus,
    this.address,
    this.pincode,
    this.bio,
    this.isFulltimeJob,
    this.currentDevice,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.callRate,
    this.chatRate,
    this.videoCallRate,
    this.privateCallRate,
    this.anonymousCallRate,
    this.isLive,
    this.isOnline,
    this.isAudioCallAvailable,
    this.isAnonymousCallAvailable,
    this.isPrivateCallAvailable,
    this.isVideoCallAvailable,
    this.isChatAvailable,
    this.nextUpComingTime,
    this.averageRating,
    this.walletAmount,
    this.totalRatingCount,
    this.fcmToken,
    this.chatGroupId,
    this.callChannelName,
    this.isFollowing,
  });

  VendorDetailsModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        name = json['name'] as String?,
        email = json['email'] as String?,
        mobile = json['mobile'] as String?,
        avatar = json['avatar'] as String?,
        dob = json['dob'] as String?,
        gender = json['gender'] as String?,
        skills = (json['skills'] as List?)?.map((dynamic e) => e as String).toList(),
        experienceYear = json['experienceYear'] as int?,
        languages = (json['languages'] as List?)?.map((dynamic e) => e as String).toList(),
        maritalStatus = json['maritalStatus'] as String?,
        workingHours = json['workingHours'] as int?,
        exclusiveStatus = json['exclusiveStatus'] as bool?,
        address = json['address'] as String?,
        pincode = json['pincode'] as int?,
        bio = json['bio'] as String?,
        isFulltimeJob = json['isFulltimeJob'] as bool?,
        currentDevice = json['currentDevice'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as int?,
        callRate = json['callRate'] as int?,
        chatRate = json['chatRate'] as int?,
        videoCallRate = json['videoCallRate'] as int?,
        privateCallRate = json['privateCallRate'] as int?,
        anonymousCallRate = json['anonymousCallRate'] as int?,
        isLive = json['isLive'] as bool?,
        isOnline = json['isOnline'] as bool?,
        isAudioCallAvailable = json['isAudioCallAvailable'] as bool?,
        isAnonymousCallAvailable = json['isAnonymousCallAvailable'] as bool?,
        isPrivateCallAvailable = json['isPrivateCallAvailable'] as bool?,
        isVideoCallAvailable = json['isVideoCallAvailable'] as bool?,
        isChatAvailable = json['isChatAvailable'] as bool?,
        nextUpComingTime = json['nextUpComingTime'] as dynamic,
        averageRating = json['averageRating'] as dynamic,
        walletAmount = json['walletAmount'] as dynamic,
        totalRatingCount = json['totalRatingCount'] as int?,
        fcmToken = json['fcmToken'] as String?,
        chatGroupId = json['chatGroupId'] as String?,
        callChannelName = json['callChannelName'] as String?,
        isFollowing = json['isFollowing'] as bool?;

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'avatar': avatar,
    'dob': dob,
    'gender': gender,
    'skills': skills,
    'experienceYear': experienceYear,
    'languages': languages,
    'maritalStatus': maritalStatus,
    'workingHours': workingHours,
    'exclusiveStatus': exclusiveStatus,
    'address': address,
    'pincode': pincode,
    'bio': bio,
    'isFulltimeJob': isFulltimeJob,
    'currentDevice': currentDevice,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': v,
    'callRate': callRate,
    'chatRate': chatRate,
    'videoCallRate': videoCallRate,
    'privateCallRate': privateCallRate,
    'anonymousCallRate': anonymousCallRate,
    'isLive': isLive,
    'isOnline': isOnline,
    'isAudioCallAvailable': isAudioCallAvailable,
    'isVideoCallAvailable': isVideoCallAvailable,
    'isChatAvailable': isChatAvailable,
    'nextUpComingTime': nextUpComingTime,
    'averageRating': averageRating,
    'walletAmount': walletAmount,
    'totalRatingCount': totalRatingCount,
    'fcmToken': fcmToken,
    'chatGroupId': chatGroupId,
    'callChannelName': callChannelName,
    'isFollowing': isFollowing,
  };

  @override
  String toString() {
    return '{id: $id, name: $name, email: $email, mobile: $mobile, avatar: $avatar, dob: $dob, gender: $gender, skills: $skills, experienceYear: $experienceYear, languages: $languages, maritalStatus: $maritalStatus, workingHours: $workingHours, exclusiveStatus: $exclusiveStatus,'
        ' address: $address, pincode: $pincode, bio: $bio, isFulltimeJob: $isFulltimeJob, currentDevice: $currentDevice,'
        ' createdAt: $createdAt, updatedAt: $updatedAt, v: $v, callRate: $callRate, chatRate: $chatRate,'
        ' videoCallRate: $videoCallRate, privateCallRate : $privateCallRate, anonymousCallRate : $anonymousCallRate'
        'isLive: $isLive, isOnline: $isOnline, isAudioCallAvailable : $isAudioCallAvailable,isVideoCallAvailable: $isVideoCallAvailable isChatAvailable :$isChatAvailable'
        'nextUpComingTime : $nextUpComingTime'
        ' averageRating: $averageRating, totalRatingCount: $totalRatingCount,'
        ' fcmToken : $fcmToken ,chatGroupId: $chatGroupId , callChannelName: $callChannelName,isFollowing : $isFollowing }';
  }
}
