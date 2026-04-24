class TrainingVideoModel {
  final String? id;
  final String? title;
  final String? url;

  TrainingVideoModel({
    this.id,
    this.title,
    this.url,
  });

  TrainingVideoModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        title = json['title'] as String?,
        url = json['url'] as String?;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'url': url,
      };
}
