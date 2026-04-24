class VendorRatingModel {
  final String? id;
  final String? uid;
  final String? vendorId;
  final String? userId;
  final int? rating;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final UserDetails? userDetails;

  VendorRatingModel({
    this.id,
    this.uid,
    this.vendorId,
    this.userId,
    this.rating,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userDetails,
  });

  VendorRatingModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        uid = json['uid'] as String?,
        vendorId = json['vendorId'] as String?,
        userId = json['userId'] as String?,
        rating = json['rating'] as int?,
        description = json['description'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        v = json['__v'] as int?,
        userDetails = (json['userDetails'] as Map<String, dynamic>?) != null
            ? UserDetails.fromJson(json['userDetails'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'uid': uid,
        'vendorId': vendorId,
        'userId': userId,
        'rating': rating,
        'description': description,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
        'userDetails': userDetails?.toJson(),
      };
}

class UserDetails {
  final String? name;
  final String? uid;
  final String? lastName;
  final String? email;
  final String? avatar;

  UserDetails({
    this.name,
    this.uid,
    this.lastName,
    this.email,
    this.avatar,
  });

  UserDetails.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        uid = json['uid'] as String?,
        lastName = json['lastName'] as String?,
        email = json['email'] as String?,
        avatar = json['avatar'] as String?;

  Map<String, dynamic> toJson() => {
        'name': name,
        'uid': uid,
        'lastName': lastName,
        'email': email,
        'avatar': avatar,
      };
}
