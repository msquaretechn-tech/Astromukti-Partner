class CallWaitingModel {
  final String? vendorId;
  final String? userId;
  final String? waitType;
  final String? name;
  final String? email;

  CallWaitingModel({
    this.vendorId,
    this.userId,
    this.waitType,
    this.name,
    this.email,
  });

  CallWaitingModel.fromJson(Map<String, dynamic> json)
      : vendorId = json['vendorId'] as String?,
        userId = json['userId'] as String?,
        waitType = json['waitType'] as String?,
        name = json['name'] as String?,
        email = json['email'] as String?;

  Map<String, dynamic> toJson() => {'vendorId': vendorId, 'userId': userId, 'waitType': waitType, 'name': name, 'email': email};

  @override
  String toString() {
    return '''{'vendorId' : $vendorId,'userId' : $userId,'waitType' : $waitType,'name' : $name,'email' : $email}''';
  }
}
