class BookingModel {
  final String? id;
  final String? vendorId;
  final String? userId;
  final String? waitType;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? name;
  final String? lastName;
  final String? email;
  final String? dob;
  final String? astrologerName;

  BookingModel({
    this.id,
    this.vendorId,
    this.userId,
    this.waitType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.lastName,
    this.email,
    this.dob,
    this.astrologerName,
  });

  BookingModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        vendorId = json['vendorId'] as String?,
        userId = json['userId'] as String?,
        waitType = json['waitType'] as String?,
        status = json['status'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        name = json['name'] as String?,
        lastName = json['lastName'] as String?,
        email = json['email'] as String?,
        dob = json['dob'] as String?,
        astrologerName = json['astrologerName'] as String?;

  Map<String, dynamic> toJson() => {
    '_id' : id,
    'vendorId' : vendorId,
    'userId' : userId,
    'waitType' : waitType,
    'status' : status,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'name' : name,
    'lastName' : lastName,
    'email' : email,
    'dob' : dob,
    'astrologerName' : astrologerName
  };
}