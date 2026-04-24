class VendorProfileModel {
  final String? id;
  final String? uid;
  final String? name;
  final String? workingPlatform;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? password;
  final String? avatar;
  final List<dynamic>? otherImages;
  final String? aadharBack;
  final String? aadharFront;
  final String? panImage;
  final String? dob;
  final String? gender;
  final List<String>? skills;
  final dynamic? experienceYear;
  final List<String>? languages;
  final String? maritalStatus;
  final dynamic? workingHours;
  final bool? exclusiveStatus;
  final String? city;
  final dynamic? pincode;
  final String? state;
  final String? country;
  final String? learningAddress;
  final String? bio;
  final bool? isFulltimeJob;
  final String? currentDevice;
  final dynamic? callRate;
  final dynamic? videoCallRate;
  final dynamic? chatRate;
  final dynamic? emergencyCallRate;
  final dynamic? privateCallRate;
  final dynamic? anonymousCallRate;
  final bool? isLive;
  final bool? isOnline;
  final bool? isAudioCallAvailable;
  final bool? isVideoCallAvailable;
  final bool? isChatAvailable;
  final bool? isNotificationOn;
  final bool? isNowAvailable;
  final List<dynamic>? Followers;
  final String? createdAt;
  final String? updatedAt;
  final dynamic? v;
  final String? bankName;
  final String? accountHolderName;
  final String? ifscCode;
  final dynamic accountNumber;
  final dynamic totalTransaction;
  final dynamic nextUpComingTime;
  final dynamic walletAmount;

  VendorProfileModel(
      {this.id,
      this.uid,
      this.name,
      this.workingPlatform,
      this.lastName,
      this.email,
      this.mobile,
      this.password,
      this.avatar,
      this.otherImages,
      this.aadharBack,
      this.aadharFront,
      this.panImage,
      this.dob,
      this.gender,
      this.skills,
      this.experienceYear,
      this.languages,
      this.maritalStatus,
      this.workingHours,
      this.exclusiveStatus,
      this.city,
      this.pincode,
      this.state,
      this.country,
      this.learningAddress,
      this.bio,
      this.isFulltimeJob,
      this.currentDevice,
      this.callRate,
      this.videoCallRate,
      this.chatRate,
      this.emergencyCallRate,
      this.privateCallRate,
      this.anonymousCallRate,
      this.isLive,
      this.isOnline,
      this.isAudioCallAvailable,
      this.isVideoCallAvailable,
      this.isChatAvailable,
      this.isNotificationOn,
      this.isNowAvailable,
      this.Followers,
      this.createdAt,
      this.updatedAt,
      this.v,
      this.bankName,
      this.accountHolderName,
      this.ifscCode,
      this.accountNumber,
      this.totalTransaction,
      this.walletAmount,
      this.nextUpComingTime}); // Include new field in constructor

  VendorProfileModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        uid = json['uid'] as String?,
        name = json['name'] as String?,
        workingPlatform = json['workingPlatform'] as String?,
        lastName = json['lastName'] as String?,
        email = json['email'] as String?,
        mobile = json['mobile'] as String?,
        password = json['password'] as String?,
        avatar = json['avatar'] as String?,
        otherImages = json['otherImages'] as List?,
        aadharBack = json['aadharBack'] as String?,
        aadharFront = json['aadharFront'] as String?,
        panImage = json['panImage'] as String?,
        dob = json['dob'] as String?,
        gender = json['gender'] as String?,
        skills =
            (json['skills'] as List?)?.map((dynamic e) => e as String).toList(),
        experienceYear = json['experienceYear'] as dynamic?,
        languages = (json['languages'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        maritalStatus = json['maritalStatus'] as String?,
        workingHours = json['workingHours'] as dynamic?,
        exclusiveStatus = json['exclusiveStatus'] as bool?,
        city = json['city'] as String?,
        pincode = json['pincode'] as dynamic?,
        state = json['state'] as String?,
        country = json['country'] as String?,
        learningAddress = json['learningAddress'] as String?,
        bio = json['bio'] as String?,
        isFulltimeJob = json['isFulltimeJob'] as bool?,
        currentDevice = json['currentDevice'] as String?,
        callRate = json['callRate'] as dynamic?,
        videoCallRate = json['videoCallRate'] as dynamic?,
        chatRate = json['chatRate'] as dynamic?,
        emergencyCallRate = json['emergencyCallRate'] as dynamic?,
        privateCallRate = json['privateCallRate'] as dynamic?,
        anonymousCallRate = json['anonymousCallRate'] as dynamic?,
        isLive = json['isLive'] as bool?,
        isOnline = json['isOnline'] as bool?,
        isAudioCallAvailable = json['isAudioCallAvailable'] as bool?,
        isVideoCallAvailable = json['isVideoCallAvailable'] as bool?,
        isChatAvailable = json['isChatAvailable'] as bool?,
        isNotificationOn = json['isNotificationOn'] as bool?,
        isNowAvailable = json['isNowAvailable'] as bool?,
        Followers = json['Followers'] as List?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as dynamic?,
        bankName = json['bankName'] as String?,
        accountHolderName = json['accountHolderName'] as String?,
        ifscCode = json['ifscCode'] as String?,
        accountNumber = json['accountNumber'] as dynamic?,
        totalTransaction = json['totalTransaction'] as dynamic,
        walletAmount = json['walletAmount'] as dynamic,
        nextUpComingTime = json["nextUpComingTime"] as dynamic;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'uid': uid,
        'name': name,
        'workingPlatform': workingPlatform,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'avatar': avatar,
        'otherImages': otherImages,
        'aadharBack': aadharBack,
        'aadharFront': aadharFront,
        'panImage': panImage,
        'dob': dob,
        'gender': gender,
        'skills': skills,
        'experienceYear': experienceYear,
        'languages': languages,
        'maritalStatus': maritalStatus,
        'workingHours': workingHours,
        'exclusiveStatus': exclusiveStatus,
        'city': city,
        'pincode': pincode,
        'state': state,
        'country': country,
        'learningAddress': learningAddress,
        'bio': bio,
        'isFulltimeJob': isFulltimeJob,
        'currentDevice': currentDevice,
        'callRate': callRate,
        'videoCallRate': videoCallRate,
        'chatRate': chatRate,
        'emergencyCallRate': emergencyCallRate,
        'privateCallRate': privateCallRate,
        'anonymousCallRate': anonymousCallRate,
        'isLive': isLive,
        'isOnline': isOnline,
        'isAudioCallAvailable': isAudioCallAvailable,
        'isVideoCallAvailable': isVideoCallAvailable,
        'isChatAvailable': isChatAvailable,
        'isNowAvailable': isNowAvailable,
        'Followers': Followers,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
        'bankName': bankName,
        'accountHolderName': accountHolderName,
        'ifscCode': ifscCode,
        'accountNumber': accountNumber,
        'totalTransaction': totalTransaction,
        'walletAmount': walletAmount,
        'nextUpComingTime': nextUpComingTime
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
