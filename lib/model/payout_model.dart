class WithdrawalResponse {
  final int statusCode;
  final List<WithdrawalData> data;
  final String message;
  final bool success;

  WithdrawalResponse({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      statusCode: json['statusCode'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => WithdrawalData.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

class WithdrawalData {
  final String id;
  final String vendorId;
  final String status;
  final double amount;
  final String transactionId;
  final String paymentMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VendorDetails vendorDetails;

  WithdrawalData({
    required this.id,
    required this.vendorId,
    required this.status,
    required this.amount,
    required this.transactionId,
    required this.paymentMode,
    required this.createdAt,
    required this.updatedAt,
    required this.vendorDetails,
  });

  factory WithdrawalData.fromJson(Map<String, dynamic> json) {
    return WithdrawalData(
      id: json['_id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      status: json['status'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      transactionId: json['transactionId'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      vendorDetails:
      VendorDetails.fromJson(json['vendorDetails'] ?? {}),
    );
  }
}

class VendorDetails {
  final String id;
  final String name;
  final String email;
  final double walletAmount;

  VendorDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.walletAmount,
  });

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    return VendorDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      walletAmount:
      double.tryParse(json['walletAmount'].toString()) ?? 0.0,
    );
  }
}