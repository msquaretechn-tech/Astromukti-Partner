class LoginHistoryModel {
  final String? id;
  final String? vendorId;
  final String? startTime;
  final String? endTime;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final VendorDetails? vendorDetails;

  LoginHistoryModel({
    this.id,
    this.vendorId,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.vendorDetails,
  });

  LoginHistoryModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        vendorId = json['vendorId'] as String?,
        startTime = json['startTime'] as String?,
        endTime = json['endTime'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as int?,
        vendorDetails = (json['vendorDetails'] as Map<String, dynamic>?) != null
            ? VendorDetails.fromJson(
                json['vendorDetails'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'vendorId': vendorId,
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
        'vendorDetails': vendorDetails?.toJson()
      };
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
