class VendorBlogDetailModel {
  final String? id;
  final String? vendorId;
  final String? heading;
  final String? title;
  final String? description;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  VendorBlogDetailModel({
    this.id,
    this.vendorId,
    this.heading,
    this.title,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  VendorBlogDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        vendorId = json['vendorId'] as String?,
        heading = json['heading'] as String?,
        title = json['title'] as String?,
        description = json['description'] as String?,
        image = json['image'] as String?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?;

  Map<String, dynamic> toJson() => {
    '_id' : id,
    'vendorId' : vendorId,
    'heading' : heading,
    'title' : title,
    'description' : description,
    'image' : image,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt
  };

  @override
  String toString() {
    return '{id: $id, vendorId: $vendorId, heading: $heading, title: $title, description: $description, image: $image, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}