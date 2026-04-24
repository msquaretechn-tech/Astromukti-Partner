class TransactionEarningModel {
  final int? todayEarning;
  final int? weeklyEarning;
  final int? monthlyEarning;
  final int? totalEarning;

  TransactionEarningModel({
    this.todayEarning,
    this.weeklyEarning,
    this.monthlyEarning,
    this.totalEarning,
  });

  TransactionEarningModel.fromJson(Map<String, dynamic> json)
      : todayEarning = json['todayEarning'] as int?,
        weeklyEarning = json['weeklyEarning'] as int?,
        monthlyEarning = json['monthlyEarning'] as int?,
        totalEarning = json['totalEarning'] as int?;

  Map<String, dynamic> toJson() => {
    'todayEarning' : todayEarning,
    'weeklyEarning' : weeklyEarning,
    'monthlyEarning' : monthlyEarning,
    'totalEarning' : totalEarning
  };
}