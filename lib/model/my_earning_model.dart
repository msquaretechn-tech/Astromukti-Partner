class MyEarningModel {
  final Id? id;
  final dynamic totalAmount;
  final double? totalDuration;
  final int? totalTransactions;
  final List<String>? type;

  MyEarningModel({
    this.id,
    this.totalAmount,
    this.totalDuration,
    this.totalTransactions,
    this.type,
  });

  MyEarningModel.fromJson(Map<String, dynamic> json)
      : id = (json['_id'] as Map<String, dynamic>?) != null
            ? Id.fromJson(json['_id'] as Map<String, dynamic>)
            : null,
        totalAmount = json['totalAmount'],
        totalDuration = (json['totalDuration'] is int)
            ? (json['totalDuration'] as int).toDouble()
            : json['totalDuration'] as double?,
        totalTransactions = json['totalTransactions'] as int?,
        type =
            (json['type'] as List?)?.map((dynamic e) => e.toString()).toList();

  Map<String, dynamic> toJson() => {
        '_id': id?.toJson(),
        'totalAmount': totalAmount,
        'totalDuration': totalDuration,
        'totalTransactions': totalTransactions,
        'type': type
      };
}

class Id {
  final int? year;
  final int? month;

  Id({
    this.year,
    this.month,
  });

  Id.fromJson(Map<String, dynamic> json)
      : year = json['year'] as int?,
        month = json['month'] as int?;

  Map<String, dynamic> toJson() => {'year': year, 'month': month};
}
