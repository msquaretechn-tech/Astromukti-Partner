class PaymentDetailModel {
  final String? id;
  final String? userId;
  final String? vendorId;
  final String? transactionStatus;
  final int? transactionAmount;
  final String? createdAt;
  final String? updatedAt;

  PaymentDetailModel({
    this.id,
    this.userId,
    this.vendorId,
    this.transactionStatus,
    this.transactionAmount,
    this.createdAt,
    this.updatedAt,
  });

  PaymentDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        userId = json['userId'] as String?,
        vendorId = json['vendorId'] as String?,
        transactionStatus = json['transactionStatus'] as String?,
        transactionAmount = json['transactionAmount'] as int?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?;

  Map<String, dynamic> toJson() => {
    '_id' : id,
    'userId' : userId,
    'vendorId' : vendorId,
    'transactionStatus' : transactionStatus,
    'transactionAmount' : transactionAmount,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt
  };
}