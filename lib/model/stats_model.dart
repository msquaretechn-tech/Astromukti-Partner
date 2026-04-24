class StatsModel {
  final int callRequests;
  final int chatRequests;
  final int videoCallRequests;
  final double totalEarnings;
  final double walletAmount;

  StatsModel({
    required this.callRequests,
    required this.chatRequests,
    required this.videoCallRequests,
    required this.totalEarnings,
    required this.walletAmount,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      callRequests: json['callRequests'] ?? 0,
      chatRequests: json['chatRequests'] ?? 0,
      videoCallRequests: json['videoCallRequests'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      walletAmount: (json['walletAmount'] ?? 0).toDouble(),
    );
  }

  static StatsModel empty() => StatsModel(
    callRequests: 0,
    chatRequests: 0,
    videoCallRequests: 0,
    totalEarnings: 0,
    walletAmount: 0,
  );
}
