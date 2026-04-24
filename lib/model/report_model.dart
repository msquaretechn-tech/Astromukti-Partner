class ReportModel {
  final String? id;
  final String? userId;
  final String? vendorId;
  final String? status;
  final String? type;
  final dynamic? duration;
  final dynamic? amount;
  final String? createdAt;
  final String? updatedAt;
  final dynamic? v;
  final UserDetails? userDetails;
  final VendorDetails? vendorDetails;

  ReportModel({
    this.id,
    this.userId,
    this.vendorId,
    this.status,
    this.type,
    this.duration,
    this.amount,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userDetails,
    this.vendorDetails,
  });

  ReportModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        userId = json['userId'] as String?,
        vendorId = json['vendorId'] as String?,
        status = json['status'] as String?,
        type = json['type'] as String?,
        duration = json['duration'] as dynamic?,
        amount = json['amount'] as dynamic?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as dynamic?,
        userDetails = (json['userDetails'] as Map<String, dynamic>?) != null
            ? UserDetails.fromJson(json['userDetails'] as Map<String, dynamic>)
            : null,
        vendorDetails = (json['vendorDetails'] as Map<String, dynamic>?) != null
            ? VendorDetails.fromJson(
                json['vendorDetails'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'vendorId': vendorId,
        'status': status,
        'type': type,
        'duration': duration,
        'amount': amount,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
        'userDetails': userDetails?.toJson(),
        'vendorDetails': vendorDetails?.toJson()
      };
}

class UserDetails {
  final String? name;
  final String? uid;
  final String? avatar;
  final String? lastName;

  UserDetails({
    this.name,
    this.uid,
    this.avatar,
    this.lastName,
  });

  UserDetails.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        uid = json['uid'] as String?,
        avatar = json['avatar'] as String?,
        lastName = json['lastName'] as String?;

  Map<String, dynamic> toJson() =>
      {'name': name,'uid': uid, 'avatar': avatar, 'lastName': lastName};
}

class VendorDetails {
  final String? name;
  final String? avatar;

  VendorDetails({
    this.name,
    this.avatar,
  });

  VendorDetails.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        avatar = json['avatar'] as String?;

  Map<String, dynamic> toJson() => {'name': name, 'avatar': avatar};
}
